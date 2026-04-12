# app/controllers/admin/rooms_controller.rb
class Admin::RoomsController < Admin::BaseController
  before_action :set_room, only: [:show]

  def index
    @rooms = Room.all
  end

  def show
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    day_bookings  = @room.bookings.on_date(@selected_date).to_a
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
    @room = Room.find(params[:id])

    unless current_user.admin? || current_user.superadmin? ## loosen temporaily, no need superadmin
      redirect_to root_path, alert: "Access denied."
    end
  end
end