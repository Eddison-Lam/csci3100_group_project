# app/services/booking_lock_service.rb
class BookingLockService
  LOCK_PREFIX = "booking_lock"
  RESOURCE_LOCKS_PREFIX = "resource_locks"

  class << self
    # Try to aquire a lock
    # return lock_token or nil
    def acquire_lock(user:, resource:, date:, start_slot:, end_slot:)
      # check if lock or booked
      return nil if slots_unavailable?(resource, date, start_slot, end_slot)

      lock_token = SecureRandom.urlsafe_base64(32)
      timeout_seconds = Setting.get(:booking_lock_timeout_minutes, 5).to_i * 60

      lock_data = {
        user_id: user.id,
        resource_id: resource.id,
        booking_date: date.to_s,
        start_slot: start_slot,
        end_slot: end_slot,
        created_at: Time.current.to_i
      }

      # store lock in Redis
      lock_key = lock_key(lock_token)
      redis.mapped_hmset(lock_key, lock_data)
      redis.expire(lock_key, timeout_seconds)

      # Add to resource lock index for quick lookup
      resource_key = resource_locks_key(resource.id, date)
      redis.sadd(resource_key, lock_token)
      redis.expire(resource_key, timeout_seconds + 60) # 60 seconds to prevent orphaned keys

      # create slot lock keys for quick availability checks
      (start_slot...end_slot).each do |slot|
        slot_key = slot_lock_key(resource.id, date, slot)
        redis.set(slot_key, lock_token, ex: timeout_seconds)
      end

      lock_token
    rescue Redis::BaseError => e
      Rails.logger.error("Failed to acquire lock: #{e.message}")
      nil
    end

    # validate if the lock is belong to a user
    def validate_lock(lock_token, user_id)
      lock_data = get_lock(lock_token)
      return false unless lock_data

      lock_data[:user_id].to_i == user_id
    end

    # release a lock
    def release_lock(lock_token)
      lock_data = get_lock(lock_token)
      return false unless lock_data

      # delete slot locks
      resource_id = lock_data[:resource_id]
      date = lock_data[:booking_date]
      start_slot = lock_data[:start_slot].to_i
      end_slot = lock_data[:end_slot].to_i

      (start_slot...end_slot).each do |slot|
        redis.del(slot_lock_key(resource_id, date, slot))
      end

      # remove from resource lock index
      redis.srem(resource_locks_key(resource_id, date), lock_token)

      # delete the lock
      redis.del(lock_key(lock_token))

      true
    rescue Redis::BaseError => e
      Rails.logger.error("Failed to release lock: #{e.message}")
      false
    end

    # get lock data
    def get_lock(lock_token)
      data = redis.hgetall(lock_key(lock_token))
      return nil if data.empty?

      data.symbolize_keys
    end

    # get remaining time for a lock
    def time_remaining(lock_token)
      ttl = redis.ttl(lock_key(lock_token))
      ttl > 0 ? ttl : 0
    end

    # check if any slot in the range is unavailable (booked or locked)
    def slots_unavailable?(resource, date, start_slot, end_slot)
      # check existing bookings in the database
      bookings_exist = Booking.where(
        resource_id: resource.id,
        booking_date: date
      ).active.where(
        "start_slot < ? AND end_slot > ?", end_slot, start_slot
      ).exists?

      return true if bookings_exist

      # check locks in Redis
      (start_slot...end_slot).any? do |slot|
        redis.exists?(slot_lock_key(resource.id, date, slot))
      end
    end

    # get all locked slots for a resource and date
    def locked_slots(resource_id, date)
      lock_tokens = redis.smembers(resource_locks_key(resource_id, date))

      locked = Set.new
      lock_tokens.each do |token|
        lock_data = get_lock(token)
        next unless lock_data

        start_slot = lock_data[:start_slot].to_i
        end_slot = lock_data[:end_slot].to_i
        (start_slot...end_slot).each { |s| locked.add(s) }
      end

      locked
    end

    # get active lock for a user (if any)
    def user_active_lock(user_id)
      # scan for all possible lock（save in user session "lock_token"）
      # I do not want to do this, so just return nil, lol
      nil
    end

    # periodic cleanup of expired locks (can be called by a scheduled job)
    def cleanup_expired_locks
      # Redis TTL will automatically remove expired locks
      # can clean orphaned index entries if needed
    end

    private

    def redis
      @redis ||= Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
    end

    def lock_key(token)
      "#{LOCK_PREFIX}:#{token}"
    end

    def resource_locks_key(resource_id, date)
      "#{RESOURCE_LOCKS_PREFIX}:#{resource_id}:#{date}"
    end

    def slot_lock_key(resource_id, date, slot)
      "slot_lock:#{resource_id}:#{date}:#{slot}"
    end
  end
end
