class BookingService
  Result = Struct.new(:success?, :booking, :error, :lock_token, keyword_init: true)

  def self.create(user:, resource:, date:, start_slot:, end_slot:, purpose:, notes: nil, lock_token: nil)
    # validate lock token
    unless lock_token && BookingLockService.validate_lock(lock_token, user.id)
      return Result.new(
        success?: false,
        error: "Your booking session has expired. Please select the time slots again."
      )
    end

    booking = nil

    ActiveRecord::Base.transaction do
      # Pessimistic lock as last defense
      Booking.where(resource_id: resource.id, booking_date: date)
             .active
             .lock("FOR UPDATE")
             .load

      booking = Booking.new(
        user: user,
        resource: resource,
        booking_date: date,
        start_slot: start_slot,
        end_slot: end_slot,
        purpose: purpose,
        notes: notes
      )

      unless booking.save
        return Result.new(
          success?: false,
          booking: booking,
          error: booking.errors.full_messages.join(", ")
        )
      end

      # release lock
      BookingLockService.release_lock(lock_token)
    end

    post_create(booking)

    Result.new(success?: true, booking: booking)
  rescue ActiveRecord::Deadlocked
    Result.new(success?: false, error: "System busy, please retry")
  end

  private

  # After a booking is created, handle bitmap updates and schedule expiry if needed.
  def self.post_create(booking)
    if booking.pending_payment?
      # Mark slots as pending so others see them as blocked
      service = ResourceAvailabilityService.new(booking.resource)
      service.set_pending_slots(booking.booking_date, booking.start_slot, booking.end_slot)
      # Schedule auto-cancel after payment deadline
      BookingPaymentExpiryJob.set(wait_until: booking.payment_expires_at).perform_later(booking.id)
    else
      # Free resource — immediately occupy
      booking.update_occupied_bitmap
    end
  end
end
