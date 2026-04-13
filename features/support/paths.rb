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
      student_root_path
    when "the admin home page"
      admin_root_path
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
      my_bookings_path
    when "the booking confirmation page"
      new_booking_path   # adjust if needed
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)