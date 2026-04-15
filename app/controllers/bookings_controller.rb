class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [ :show, :destroy, :payment, :pay ]

  # My Bookings page
  def index
    @tab = params[:tab] || "rooms"
    base = current_user.bookings.includes(:resource).order(booking_date: :desc, start_slot: :asc)
    @bookings = if @tab == "equipment"
      base.joins(:resource).where(resources: { type: "Equipment" })
    else
      base.joins(:resource).where(resources: { type: "Room" })
    end
  end

  # Booking confirmation preview (before creating)
  def new
    @resource = Resource.find(params[:resource_id])
    @date = Date.parse(params[:date])
    @start_slot = params[:start_slot].to_i
    @end_slot = params[:end_slot].to_i
    @lock_token = params[:lock_token]
    @booking = Booking.new(resource: @resource, start_slot: @start_slot, end_slot: @end_slot, booking_date: @date)
    @duration_slots = @booking.duration_slots
    @booking.send(:calculate_total_cost)
    @total_cost = @booking.total_cost
  end

  # Create the booking
  def create
    resource = Resource.find(params[:resource_id])
    date = Date.parse(params[:date])
    start_slot = params[:start_slot].to_i
    end_slot = params[:end_slot].to_i

    result = BookingService.create(
      user: current_user,
      resource: resource,
      date: date,
      start_slot: start_slot,
      end_slot: end_slot,
      purpose: params[:purpose],
      notes: params[:notes],
      lock_token: params[:lock_token]
    )

    if result.success?
      booking = result.booking
      if booking.pending_payment?
        redirect_to payment_booking_path(booking), notice: "Booking reserved. Please complete payment within 30 minutes."
      else
        # Free booking — confirmed immediately, bitmap already set by BookingService
        BookingMailer.confirmation_email(booking).deliver_later
        redirect_to booking_path(booking), notice: "Booking confirmed!"
      end
    else
      redirect_to resource.is_a?(Room) ? room_path(resource, date: params[:date]) : equipment_path(resource, date: params[:date]),
                  alert: result.error
    end
  end

  # Booking detail
  def show
    if params[:payment_success] == "true" && @booking.stripe_session_id.present?
      begin
        stripe_session = Stripe::Checkout::Session.retrieve(@booking.stripe_session_id)

        if stripe_session.payment_status == "paid"
          @booking.update!(status: :confirmed, paid_at: Time.current)
          @booking.update_occupied_bitmap
          @booking.clear_pending_bitmap
          BookingMailer.confirmation_email(@booking).deliver_now

          @booking.update!(stripe_session_id: nil)
          flash[:notice] = "Payment successful! Booking confirmed."
        end
      rescue Stripe::StripeError => e
        flash[:alert] = "Payment failed: #{e.message}"
      end
    end
  end

  # Cancel booking
  def destroy
    # still not paid, just delete the record and release the lock (if any)
    if @booking.status != "confirmed"
      if params[:lock_token].present?
        BookingLockService.release_lock(params[:lock_token])
      end

      @booking.destroy

      redirect_to bookings_path, notice: "Booking has been cancelled and removed."
      return
    end

    # if paid, update status to cancelled and clear occupied bitmap
    @booking.update!(status: :cancelled)
    @booking.clear_occupied_bitmap
    redirect_to bookings_path, notice: "Booking cancelled."
  end

  # Mock payment page
  def payment
    unless @booking.pending_payment?
      redirect_to booking_path(@booking), alert: "Payment not required or already completed."
      return
    end

    if @booking.payment_expires_at && Time.current > @booking.payment_expires_at
      @booking.update!(status: :cancelled)
      @booking.clear_pending_bitmap
      redirect_to bookings_path, alert: "Payment window expired. Booking cancelled."
    end
  end

  # Process mock payment
  def pay
    unless @booking.pending_payment?
      redirect_to booking_path(@booking), alert: "Payment not required or already completed."
      return
    end

    if @booking.payment_expires_at && Time.current > @booking.payment_expires_at
      @booking.update!(status: :cancelled)
      @booking.clear_pending_bitmap
      redirect_to bookings_path, alert: "Payment window expired. Booking cancelled."
      return
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card", "alipay", "wechat_pay" ],
      line_items: [ {
        price_data: {
          currency: "hkd",
          product_data: {
            name: @booking.resource.name,
            description: "Booking on #{@booking.booking_date.strftime('%Y-%m-%d')}"
          },
          unit_amount: (@booking.total_cost * 100).to_i
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: booking_url(@booking) + "?payment_success=true",
      cancel_url:  booking_url(@booking),
      metadata: { booking_id: @booking.id },
      payment_method_options: {
        wechat_pay: {
          client: "web"
        }
      },
      customer_email: @booking.user.email
    )

    @booking.update!(stripe_session_id: session.id)

    redirect_to session.url, allow_other_host: true
  end

  # Release a booking lock (called via sendBeacon when user leaves confirm page)
  def release_lock
    lock_token = params[:lock_token]
    if lock_token.present? && BookingLockService.validate_lock(lock_token, current_user.id)
      BookingLockService.release_lock(lock_token)
    end
    head :no_content
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  end
end
