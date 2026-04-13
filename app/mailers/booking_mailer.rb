class BookingMailer < ApplicationMailer
  def confirmation_email(booking)
    default from: "CUHK Booking System <noreply@cuhk-booking.edu.hk>"
    @booking = booking
    @resource = booking.resource
    @user = booking.user
    mail(to: @user.email, subject: "Booking Confirmed — #{@resource.name}")
  end
end
