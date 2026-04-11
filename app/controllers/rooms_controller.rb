class RoomsController < ApplicationController
  include BookableResource  # include Concern

  before_action :authenticate_user!

  def index
    @rooms = Room.filtered(filter_params)
    @buildings = Room.available_buildings
    @room_types = Room.available_room_types(buildings: filter_params[:buildings])
  end

  # show and availability provided by Concern/BookableResource
  # deleted

  private

  # implement concern method
  def set_resource
    @resource = @room = Room.find(params[:id])
  end

  def index_path
    rooms_path
  end

  def resource_path(resource)
    room_path(resource)
  end

  def filter_params
    params.permit(:capacity, :department_id, buildings: [], room_types: [])
  end
end
