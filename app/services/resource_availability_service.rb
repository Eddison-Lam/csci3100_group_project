class ResourceAvailabilityService
  # Redis key formats
  OCCUPIED_KEY = "occupied:%<resource_id>d:%<date>s".freeze
  PENDING_KEY  = "pending:%<resource_id>d:%<date>s".freeze

  # TTL constants (in seconds)
  OCCUPIED_TTL = 86_400  # 24 hours
  PENDING_TTL  = 3600    # 1 hour

  # --- Class-level wrappers ---
  # Booking model calls these as class methods, e.g.:
  #   ResourceAvailabilityService.update_occupied_bitmap(resource_id, date, slots)
  # But the actual bitmap logic lives on instances. These wrappers bridge the gap
  # so we don't have to change every call site in the Booking model.
  def self.update_occupied_bitmap(resource_id, date, slots)
    resource = Resource.find(resource_id)
    service  = new(resource)
    service.set_occupied_slots(date, slots.min, slots.max + 1)
  end

  def self.clear_pending_bitmap(resource_id, date, slots)
    resource = Resource.find(resource_id)
    service  = new(resource)
    service.clear_pending_slots(date, slots.min, slots.max + 1)
  end

  def self.clear_occupied_bitmap(resource_id, date, slots)
    resource = Resource.find(resource_id)
    service  = new(resource)
    service.clear_occupied_slots(date, slots.min, slots.max + 1)
  end

  def initialize(resource)
    @resource = resource
  end

  # Returns availability status for all visible slots on the given date
  # Optional: pass current_user to mark "mine: true" for user's own locks
  def available_slots(date, current_user: nil)
    resource_id = @resource.id
    date_str    = date.to_s

    key_occupied = format(OCCUPIED_KEY, resource_id: resource_id, date: date_str)
    key_pending  = format(PENDING_KEY,  resource_id: resource_id, date: date_str)

    # Rebuild occupied bitmap from DB if key doesn't exist in Redis
    unless redis.exists?(key_occupied)
      rebuild_and_cache_occupied_bitmap(date)
    end

    # Ensure pending key exists (so getbit returns 0 rather than needing special handling)
    unless redis.exists?(key_pending)
      redis.set(key_pending, "\x00" * 8, ex: PENDING_TTL)
    end

    # Collect lock tokens from BookingLockService's key
    lock_key = "resource_locks:#{resource_id}:#{date_str}"
    lock_tokens = redis.smembers(lock_key) || []

    # Compute past-slot cutoff for today (HKT = UTC+8)
    hk_now = Time.now.utc + 8.hours
    is_today = date == hk_now.to_date
    # Current slot: e.g. 14:44 → slot 29 (14*2 + 1). Slots 0..28 are in the past.
    current_slot = is_today ? (hk_now.hour * 2 + (hk_now.min >= 30 ? 1 : 0)) : nil

    # Build final availability using redis.getbit for reliable bit reads
    results = []

    @resource.effective_op_start.upto(@resource.effective_op_end - 1) do |slot|
      status = :free
      mine   = false

      # Priority: past > occupied > pending > locked/pending > free
      if is_today && slot < current_slot
        status = :past
      elsif redis.getbit(key_occupied, slot) == 1
        status = :occupied
      elsif redis.getbit(key_pending, slot) == 1
        status = :pending
      elsif lock_tokens.any? { |token| lock_covers_slot?(token, slot) }
        status = :pending
        if current_user
          token = lock_tokens.find { |t| lock_covers_slot?(t, slot) }
          lock_data = redis.hgetall("booking_lock:#{token}")
          mine = lock_data["user_id"].to_i == current_user.id if lock_data.present?
        end
      end

      results << {
        slot:      slot,
        available: status == :free,
        status:    status,
        mine:      mine
      }
    end

    results
  end

  # These three methods were inside `private` before, but they need to be
  # callable from the class-level wrappers above and from services/jobs.
  # Moved them out of private so they're public instance methods now.

  # Mark slots as pending (called when user confirms)
  def set_pending_slots(date, start_slot, end_slot)
    key = format(PENDING_KEY, resource_id: @resource.id, date: date.to_s)
    (start_slot...end_slot).each do |slot|
      redis.setbit(key, slot, 1)
    end
    redis.expire(key, PENDING_TTL)
  end

  # Clear pending slots (called when job succeeds or fails)
  def clear_pending_slots(date, start_slot, end_slot)
    key = format(PENDING_KEY, resource_id: @resource.id, date: date.to_s)
    (start_slot...end_slot).each do |slot|
      redis.setbit(key, slot, 0)
    end
  end

  def set_occupied_slots(date, start_slot, end_slot)
    key = format(OCCUPIED_KEY, resource_id: @resource.id, date: date.to_s)
    (start_slot...end_slot).each do |slot|
      redis.setbit(key, slot, 1)
    end
    redis.expire(key, OCCUPIED_TTL)
  end

  # Clear occupied slots (called when a confirmed booking is cancelled)
  def clear_occupied_slots(date, start_slot, end_slot)
    key = format(OCCUPIED_KEY, resource_id: @resource.id, date: date.to_s)
    (start_slot...end_slot).each do |slot|
      redis.setbit(key, slot, 0)
    end
  end

  private

  # Rebuild only occupied bitmap from DB (confirmed bookings)
  # Uses redis.setbit for consistency with set_occupied_slots
  def rebuild_and_cache_occupied_bitmap(date)
    key = format(OCCUPIED_KEY, resource_id: @resource.id, date: date.to_s)

    confirmed_bookings = Booking.where(resource_id: @resource.id)
                                .where(booking_date: date)
                                .where(status: :confirmed)
                                .pluck(:start_slot, :end_slot)

    # Initialize key so it exists (prevents repeated rebuilds)
    redis.set(key, "\x00" * 8, ex: OCCUPIED_TTL)

    confirmed_bookings.each do |s, e|
      s.upto(e - 1) { |slot| redis.setbit(key, slot, 1) }
    end
  end

  # Check if a lock token covers the given slot
  def lock_covers_slot?(token, slot)
    lock_data = redis.hgetall("booking_lock:#{token}")
    return false unless lock_data.present?

    start_s = lock_data["start_slot"].to_i
    end_s   = lock_data["end_slot"].to_i
    slot >= start_s && slot < end_s
  end

  # Switched from Redis.current (deprecated, was never configured in an
  # initializer so it would blow up) to the shared REDIS constant from
  # config/initializers/redis.rb. BookingLockService now uses the same constant.
  def redis
    REDIS
  end
end
