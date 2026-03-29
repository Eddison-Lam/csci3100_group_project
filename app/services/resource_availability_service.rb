class ResourceAvailabilityService
  # Redis key formats
  OCCUPIED_KEY = "occupied:%<resource_id>d:%<date>s".freeze
  PENDING_KEY  = "pending:%<resource_id>d:%<date>s".freeze
  LOCK_INDEX_KEY = "locks:%<resource_id>d:%<date>s".freeze

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
    key_locks    = format(LOCK_INDEX_KEY, resource_id: resource_id, date: date_str)

    # Fetch from Redis
    occupied = redis.get(key_occupied)
    pending  = redis.get(key_pending)
    lock_tokens = redis.smembers(key_locks) || []

    # Handle cache miss for occupied (rebuild from DB)
    if occupied.nil?
      occupied = rebuild_and_cache_occupied_bitmap(date)
    end

    # Handle cache miss for pending (no rebuild, just empty bitmap)
    if pending.nil?
      pending = "\x00" * 8
      redis.set(key_pending, pending, ex: PENDING_TTL)
    end

    # Build final availability
    results = []

    @resource.effective_op_start.upto(@resource.effective_op_end) do |slot|
      status = :free
      mine   = false

      # Priority: occupied > pending > locked > free
      if bit_set?(occupied, slot)
        status = :occupied
      elsif bit_set?(pending, slot)
        status = :pending
      elsif lock_tokens.any? { |token| lock_covers_slot?(token, slot) }
        status = :locked
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

  private

  # Rebuild only occupied bitmap from DB (confirmed bookings)
  def rebuild_and_cache_occupied_bitmap(date)
    date_str = date.to_s

    confirmed_bookings = Booking.where(resource_id: @resource.id)
                                .where(booking_date: date)
                                .where(status: :confirmed)
                                .pluck(:start_slot, :end_slot)

    bitmap = "\x00" * 8

    confirmed_bookings.each do |s, e|
      s.upto(e - 1) { |slot| set_bit!(bitmap, slot) }
    end

    key = format(OCCUPIED_KEY, resource_id: @resource.id, date: date_str)
    # Changed from Redis.current (deprecated / not configured) to shared REDIS constant
    redis.set(key, bitmap, ex: OCCUPIED_TTL)

    bitmap
  end

  # Set a bit in the bitmap string
  def set_bit!(bitmap_str, slot)
    byte_idx = slot / 8
    bit_idx  = slot % 8

    bytes = bitmap_str.bytes
    bytes[byte_idx] |= (1 << bit_idx)
    bitmap_str.replace(bytes.pack("C*"))
  end

  # Check if a bit is set
  def bit_set?(bitmap_str, slot)
    return false unless bitmap_str && bitmap_str.bytesize > (slot / 8)

    byte_idx = slot / 8
    bit_idx  = slot % 8
    byte = bitmap_str.getbyte(byte_idx)
    (byte & (1 << bit_idx)) != 0
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
