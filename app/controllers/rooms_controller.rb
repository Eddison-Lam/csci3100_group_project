class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room, only: [ :show, :availability ]

  def index
    @rooms = Room.filtered(filter_params)
    @buildings = Room.available_buildings
    @room_types = Room.available_room_types(buildings: filter_params[:buildings])
  end

  def show
    @date = parse_date(params[:date]) || Date.current
    service = ResourceAvailabilityService.new(@room)
    @slots = service.available_slots(@date, current_user: current_user)
  end

  # JSON endpoint for AJAX availability refresh and lock acquisition
  def availability
    date = parse_date(params[:date]) || Date.current

    # If start_slot and end_slot provided, try to acquire a lock
    if params[:start_slot].present? && params[:end_slot].present?
      lock_token = BookingLockService.acquire_lock(
        user: current_user,
        resource: @room,
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

    service = ResourceAvailabilityService.new(@room)
    slots = service.available_slots(date, current_user: current_user)
    render json: { slots: slots, date: date.to_s }
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def filter_params
    params.permit(:capacity, :department_id, buildings: [], room_types: [])
  end

  def parse_date(str)
    Date.parse(str) if str.present?
  rescue Date::Error
    nil
  end
end
