module NavigationHelpers
  def path_to(page_name)
    case page_name.downcase
    when "the home page"
      root_path
    when "the login page"
      new_user_session_path
    when "the registration page"
      new_user_registration_path
    when "the student home page"
      root_path
    when "the admin home page"
      admin_resources_path
    when "the admin resources page"
      admin_resources_path
    when "the admin bookings page"
      admin_bookings_path
    when "the admin settings page"
      admin_settings_path
    when "the rooms page"
      rooms_path
    when "the equipment page"
      equipment_index_path
    when "the my bookings page"
      bookings_path
    when "the booking confirmation page"
      new_bookings_path
    when "the edit resource page for (.+)"
      resource_name = $1
      resource = Room.find_by(name: resource_name) || Equipment.find_by(name: resource_name)
      if resource.nil?
        raise "Resource '#{resource_name}' not found"
      end
      # 假设存在 edit_admin_resource_path 路由
      edit_admin_resource_path(resource)
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)