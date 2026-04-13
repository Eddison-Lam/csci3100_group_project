module LoginHelpers
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
  end
end

module SlotHelpers
  def time_to_slot(time_str)
    h, m = time_str.split(":").map(&:to_i)
    h * 2 + m / 30
  end

  def slot_to_time(slot)
    format("%02d:%02d", slot / 2, (slot % 2) * 30)
  end
end

module TimeHelpers
  def parse_date(date_string)
    case date_string.downcase
    when "today"
      Date.current
    when "tomorrow"
      Date.current + 1.day
    when "yesterday"
      Date.current - 1.day
    when /^(\d+) days? from now$/
      Date.current + $1.to_i.days
    when /^(\d+) days? ago$/
      Date.current - $1.to_i.days
    when /^([a-z]+) (\d+),? (\d{4})$/i # e.g., "March 20, 2026"
      Date.parse(date_string)
    else
      Date.parse(date_string) rescue nil
    end
  end

  def parse_time(time_string)
    Time.zone.parse(time_string) || Time.zone.parse("#{Date.current} #{time_string}")
  end
end

World(LoginHelpers)
World(SlotHelpers)
World(TimeHelpers)