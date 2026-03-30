class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes


  # This is a method letting user to redirect to correct page
  # if he is admin, go to admin resources dashboard
  # otherwise, stay
  protected
  def after_sign_in_path_for(resource)
    if resource.role == "admin"
      admin_resources_path
    else
      root_path
    end
  end
end
