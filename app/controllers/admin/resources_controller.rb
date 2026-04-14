class Admin::ResourcesController < Admin::BaseController
  layout "admin"

  before_action :authenticate_user!

  before_action :require_admin!

  def index
    if current_user.superadmin?
      @resources = Resource.all
    else
      @resources = Resource.where(department_id: current_user.department_id)
    end
  end

  private

  def require_admin!
    unless current_user.admin? || current_user.superadmin?
      redirect_to root_path, alert: "You are not authorized to view this page."
    end
  end
end
