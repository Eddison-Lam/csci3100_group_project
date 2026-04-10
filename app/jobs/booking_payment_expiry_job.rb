class BookingPaymentExpiryJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking
    return unless booking.pending_payment?

    # Auto-cancel if payment not received by deadline
    if booking.payment_expires_at && Time.current >= booking.payment_expires_at
      booking.update!(status: :cancelled)
      booking.clear_pending_bitmap
      Rails.logger.info "[BookingPaymentExpiryJob] Booking ##{booking.id} auto-cancelled (payment expired)"
    end
  end
end
