# app/controllers/admin/equipment_controller.rb
class Admin::EquipmentController < Admin::BaseController
  before_action :set_equipment, only: [:show]

  def index
    @equipment = Equipment.all
  end

  def show
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current

    day_bookings  = @equipment.bookings.on_date(@selected_date).to_a
    service_slots = ResourceAvailabilityService
                      .new(@equipment)
                      .available_slots(@selected_date, current_user: current_user)

    @slots = service_slots.map do |slot_hash|
      slot    = slot_hash[:slot]
      booking = day_bookings.find { |b| (b.start_slot...b.end_slot).cover?(slot) }
      slot_hash.merge(booking: booking)
    end
  end

  private

  def set_equipment
    @equipment = Equipment.find(params[:id])

    unless current_user.admin? || current_user.superadmin?
      redirect_to root_path, alert: "Access denied."
    end
  end
end