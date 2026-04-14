# app/controllers/admin/rooms_controller.rb
class Admin::RoomsController < Admin::BaseController
  before_action :set_room, only: [ :show ]

  def index
    @rooms = current_user.superadmin? ? Room.all : Room.where(department_id: current_user.department_id)
  end

  def show
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    # Fetch all bookings except cancelled ones so admin can see and edit them
    day_bookings  = @room.bookings.on_date(@selected_date).where.not(status: :cancelled).to_a
    service_slots = ResourceAvailabilityService
                      .new(@room)
                      .available_slots(@selected_date, current_user: current_user)

    @slots = service_slots.map do |slot_hash|
      slot    = slot_hash[:slot]
      booking = day_bookings.find { |b| (b.start_slot...b.end_slot).cover?(slot) }
      slot_hash.merge(booking: booking)
    end
  end

  private

  def set_room
    @room = current_user.superadmin? ? Room.find(params[:id]) : Room.find_by!(id: params[:id], department_id: current_user.department_id)

    unless current_user.can_manage?(@room)
      redirect_to root_path, alert: "Access denied."
    end
  end
end
