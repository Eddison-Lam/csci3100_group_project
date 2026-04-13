class Admin::BookingsController < Admin::BaseController
  before_action :set_booking, only: [ :update, :destroy ]

  def update
    unless current_user.admin? || current_user.superadmin?
      return redirect_back fallback_location: admin_rooms_path, alert: "Not allowed."
    end

    Rails.logger.info "[ADMIN] Updating booking #{@booking.id} with params: #{booking_params.inspect}"
    was_confirmed = @booking.status == "confirmed"
    was_pending = @booking.status == "pending_payment"

    if @booking.update(booking_params)
      Rails.logger.info "[ADMIN] Booking #{@booking.id} new status: #{@booking.status}"

      # Handle bitmap changes based on status transitions
      if was_confirmed
        if @booking.cancelled? || @booking.no_show?
          # If cancelling or marking as no_show, clear the occupied bitmap to make slots available
          @booking.clear_occupied_bitmap
        elsif @booking.pending_payment?
          # If changing confirmed to pending, clear occupied and set pending
          @booking.clear_occupied_bitmap
          ResourceAvailabilityService.update_pending_bitmap(@booking.resource_id, @booking.booking_date, (@booking.start_slot...@booking.end_slot).to_a)
        end
      elsif was_pending
        if @booking.confirmed?
          # If confirming a pending booking, mark as occupied
          @booking.update_occupied_bitmap
          @booking.clear_pending_bitmap
        elsif @booking.cancelled? || @booking.no_show?
          # If cancelling/no_show a pending booking, just clear the pending bitmap
          @booking.clear_pending_bitmap
        end
      end

      redirect_back fallback_location: admin_rooms_path, notice: "Booking updated."
    else
      Rails.logger.warn "[ADMIN] Booking #{@booking.id} update failed: #{@booking.errors.full_messages.join(', ')}"
      redirect_back fallback_location: admin_rooms_path,
                    alert: @booking.errors.full_messages.to_sentence
    end
  end

  def destroy
    unless current_user.admin? || current_user.superadmin?
      return redirect_back fallback_location: admin_rooms_path, alert: "Not allowed."
    end

    @booking.destroy
    redirect_back fallback_location: admin_rooms_path, notice: "Booking deleted."
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:status)
  end
end

  def for_slot
  resource = Resource.find(params[:resource_id])
  date     = Date.parse(params[:booking_date])
  slot     = params[:slot].to_i

  # either find existing booking covering this slot, or build a new 1-slot booking
  booking = Booking.where(resource:, booking_date: date)
                   .where("start_slot <= ? AND end_slot > ?", slot, slot)
                   .first

  unless booking
    booking = Booking.new(
      resource:      resource,
      user:          current_user,              # or some placeholder/admin user
      booking_date:  date,
      start_slot:    slot,
      end_slot:      slot + 1
    )
  end

  booking.status = params[:status]

  if booking.save
    if booking.confirmed?
      booking.update_occupied_bitmap
    elsif booking.pending_payment?
      booking.update_pending_bitmap if booking.respond_to?(:update_pending_bitmap)
    end
    redirect_back fallback_location: admin_rooms_path, notice: "Slot updated."
  else
    redirect_back fallback_location: admin_rooms_path,
                  alert: booking.errors.full_messages.to_sentence
  end
end
