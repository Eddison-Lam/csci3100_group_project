class Admin::ResourcesController < ApplicationController
  layout "admin"

  before_action :authenticate_user!

  before_action :require_admin!

  def index
    if current_user.respond_to?(:department_id)
      @resources = Resource.where(department_id: current_user.department_id)
    else
      @resources = Resource.all
    end
  end

  private

  def require_admin!
    unless current_user.role == "admin" # Make sure 'role' matches your db column
      redirect_to root_path, alert: "You are not authorized to view this page."
    end
  end
end
