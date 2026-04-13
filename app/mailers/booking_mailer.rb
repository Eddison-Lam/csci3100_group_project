class BookingMailer < ApplicationMailer
  default from: "CUHK Booking System <noreply@cuhk-booking.edu.hk>"
  def confirmation_email(booking)
    @booking = booking
    @resource = booking.resource
    @user = booking.user
    mail(to: @user.email, subject: "Booking Confirmed — #{@resource.name}")
  end
end
