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
    @duration_slots = @end_slot - @start_slot
    @total_cost = @duration_slots * @resource.price_per_unit
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
  end

  # Cancel booking
  def destroy
    if @booking.confirmed? || @booking.pending_payment?
      @booking.update!(status: :cancelled)
      @booking.clear_pending_bitmap if @booking.previous_changes.key?("status")
      redirect_to bookings_path, notice: "Booking cancelled."
    else
      redirect_to bookings_path, alert: "Cannot cancel this booking."
    end
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
      return
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

    # Mock payment success
    @booking.update!(status: :confirmed, paid_at: Time.current)
    @booking.update_occupied_bitmap
    @booking.clear_pending_bitmap
    BookingMailer.confirmation_email(@booking).deliver_later
    redirect_to booking_path(@booking), notice: "Payment successful! Booking confirmed."
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  end
end
