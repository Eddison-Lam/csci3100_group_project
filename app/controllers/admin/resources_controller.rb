class Admin::ResourcesController < ApplicationController
  layout "admin"

  before_action :authenticate_user!

  before_action :require_admin!

  def index
    @resources = current_user.superadmin? ? Resource.all : Resource.where(department_id: current_user.department_id)
  end

  private

  def require_admin!
    unless current_user.admin? || current_user.superadmin?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
