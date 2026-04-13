class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  protected

  def after_sign_in_path_for(resource)
    if resource.admin? || resource.superadmin?
      admin_rooms_path
    else
      root_path
    end
  end
end