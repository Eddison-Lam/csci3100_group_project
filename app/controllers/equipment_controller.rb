class EquipmentsController < ApplicationController
  include BookableResource  # include Concern

  before_action :authenticate_user!

  def index
    @equipments = Equipment.filtered(filter_params)
    @departments = Department.active.order(:name)
  end

  # show and availability provided by Concetn/BookableResource

  private

  # implement Concern method
  def set_resource
    @resource = @equipment = Equipment.find(params[:id])
  end

  def index_path
    equipments_path
  end

  def resource_path(resource)
    equipment_path(resource)
  end

  def filter_params
    params.permit(:department_id)
  end
end
