class BookingMailer < ApplicationMailer
  default from: "CUHK Booking System <1155212423@link.cuhk.edu.hk>"
  def confirmation_email(booking)
    @booking = booking
    @resource = booking.resource
    @user = booking.user
    time_range = "#{@resource.slot_to_time(@booking.start_slot)} to #{@resource.slot_to_time(@booking.end_slot)}"
    subject = "[Booking Confirmed] #{@resource.name} - #{@booking.booking_date} #{time_range}"
    subject = "[DEV] #{subject}" if Rails.env.development?
    mail(to: @user.email, subject: subject)
  end
end
