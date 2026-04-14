# app/controllers/admin/equipment_controller.rb
class Admin::EquipmentController < Admin::BaseController
  before_action :set_equipment, only: [ :show ]

  def index
    @equipment = current_user.superadmin? ? Equipment.all : Equipment.where(department_id: current_user.department_id)
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
    @equipment = current_user.superadmin? ? Equipment.find(params[:id]) : Equipment.find_by!(id: params[:id], department_id: current_user.department_id)

    unless current_user.can_manage?(@equipment)
      redirect_to root_path, alert: "Access denied."
    end
  end
end
