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
  end

  # Cancel booking
  def destroy
    if @booking.confirmed? || @booking.pending_payment?
      previous_status = @booking.status
      @booking.update!(status: :cancelled)
      if previous_status == "confirmed"
        @booking.clear_occupied_bitmap
      elsif previous_status == "pending_payment"
        @booking.clear_pending_bitmap
      end
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
