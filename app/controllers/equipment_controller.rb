class EquipmentController < ApplicationController
  before_action :authenticate_user!
  before_action :set_equipment, only: [ :show, :availability ]

  def index
    @equipment = Equipment.active.order(:name)
    @equipment = @equipment.where(department_id: params[:department_id]) if params[:department_id].present?
  end

  def show
    @date = parse_date(params[:date]) || Date.current
    service = ResourceAvailabilityService.new(@equipment)
    @slots = service.available_slots(@date, current_user: current_user)
  end

  def availability
    date = parse_date(params[:date]) || Date.current

    if params[:start_slot].present? && params[:end_slot].present?
      lock_token = BookingLockService.acquire_lock(
        user: current_user,
        resource: @equipment,
        date: date,
        start_slot: params[:start_slot].to_i,
        end_slot: params[:end_slot].to_i
      )
      if lock_token
        render json: { lock_token: lock_token }
      else
        render json: { error: "Slots are no longer available." }, status: :conflict
      end
      return
    end

    service = ResourceAvailabilityService.new(@equipment)
    slots = service.available_slots(date, current_user: current_user)
    render json: { slots: slots, date: date.to_s }
  end

  private

  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def parse_date(str)
    Date.parse(str) if str.present?
  rescue Date::Error
    nil
  end
end
