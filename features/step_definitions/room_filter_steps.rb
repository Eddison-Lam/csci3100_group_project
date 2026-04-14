# Steps specific to room filtering and calendar interactions

Given("today is {string} which is a Sunday") do |date_str|
  # Stub Date.current or Time.zone.today if needed
  date = Date.parse(date_str)
  allow(Date).to receive(:current).and_return(date)
  # Also may need to stub Time.zone.today
end

Given("the maximum advance booking days is {int}") do |days|
  # Set application config, e.g., Rails.application.config.max_advance_booking_days = days
  allow(Rails.application.config).to receive(:max_advance_booking_days).and_return(days)
end

When("I visit the rooms page for {string}") do |date_str|
  date = parse_date(date_str)
  visit rooms_path(date: date)
end

When("I visit the rooms page") do
  visit rooms_path
end



Given("I have not selected a specific facility") do
  # If your UI has a facility dropdown, ensure it's cleared
  if page.has_select?("Facility")
    select "", from: "Facility" rescue nil
  end
  # Otherwise, this step may be informational – you can leave it empty
end

# Need a #calendar in HTML
When("I click {string} on the calendar") do |element_text|
  within(".calendar") do
    click_link_or_button(element_text)
  end
end

When("I select slots from {string} to {string} for {string}") do |start_time, end_time, resource_name|
  resource = find_resource(resource_name)
  within(find_element_by_name(resource_name)) do
    select_slots(resource, start_time, end_time)
  end
end

When("I check the {string} slot for {string}") do |time, resource_name|
  resource = find_resource(resource_name)
  slot = find_slot_checkbox(resource, time)
  check slot[:id]
end

When("I try to select {int} consecutive slots for {string}") do |num_slots, resource_name|
  resource = find_resource(resource_name)
  # Assume first available slot at 08:00
  start_time = "08:00"
  end_time = (Time.zone.parse(start_time) + (num_slots * 30).minutes).strftime("%H:%M")
  step "I select slots from \"#{start_time}\" to \"#{end_time}\" for \"#{resource_name}\""
end

When("I leave {string} empty") do |field|
  fill_in field, with: ""
end

Then("I should see a calendar for the current month") do
  expect(page).to have_css(".calendar")
  expect(page).to have_content(Date.current.strftime("%B %Y"))
end

Then("today {string} should be highlighted on the calendar") do |date_str|
  date = parse_date(date_str)
  within(".calendar") do
    expect(find(".day[data-date='#{date}']")).to have_css(".highlight")
  end
end

Then("past dates should be disabled on the calendar") do
  past_date = Date.current - 1.day
  within(".calendar") do
    expect(page).to have_css(".day.disabled[data-date='#{past_date}']")
  end
end

Then("the selected date should be {string}") do |date_str|
  date = parse_date(date_str)
  expect(find(".selected-date")).to have_content(date.strftime("%B %-d, %Y"))
end

Then("I should see room availability for {string}") do |date_str|
  date = parse_date(date_str)
  expect(page).to have_content("Availability for #{date.strftime('%B %-d, %Y')}")
end

Then("I should see the calendar for {string}") do |month_year|
  expect(find(".calendar")).to have_content(month_year)
end

Then("dates after {string} should be disabled on the calendar") do |date_str|
  date = parse_date(date_str)
  next_day = date + 1.day
  within(".calendar") do
    expect(page).to have_css(".day.disabled[data-date='#{next_day}']")
  end
end

Then("the view mode should be {string}") do |mode|
  expect(find(".view-mode")).to have_content(mode)
end

Then("I should see the date {string}") do |date_str|
  date = parse_date(date_str)
  expect(page).to have_content(date.strftime("%B %-d, %Y"))
end

Then("I should see all rooms with their time slots for that day") do
  Room.active.each do |room|
    expect(page).to have_css("#room_#{room.id} .time-slots")
  end
end

Then("I should see slots from {string} to {string} for each room") do |start_time, end_time|
  all(".time-slots").each do |slots|
    expect(slots).to have_css(".slot[data-time='#{start_time}']")
    expect(slots).to have_css(".slot[data-time='#{end_time}']")
  end
end

Then("I should see a weekly calendar for {string}") do |resource_name|
  expect(page).to have_css(".weekly-calendar")
  expect(page).to have_content(resource_name)
end

Then("the week should show {string} to {string}") do |start_str, end_str|
  start_date = parse_date(start_str)
  end_date = parse_date(end_str)
  expect(page).to have_content("Week of #{start_date.strftime('%b %-d')} – #{end_date.strftime('%b %-d, %Y')}")
end

Then("the {string} filter should show:") do |filter_name, table|
  within("##{filter_name.parameterize}-filter") do
    table.raw.flatten.each do |item|
      expect(page).to have_content(item)
    end
  end
end

Then("the {string} filter should only show:") do |filter_name, table|
  within("##{filter_name.parameterize}-filter") do
    expected = table.raw.flatten
    actual = all("label").map(&:text)
    expect(actual).to match_array(expected)
  end
end

Then("the room {string} should display {string}") do |room_name, text|
  within(find_element_by_name(room_name)) do
    expect(page).to have_content(text)
  end
end

Then("the room card for {string} should show:") do |room_name, table|
  within(find_element_by_name(room_name)) do
    table.rows_hash.each do |key, value|
      expect(page).to have_content(value)
    end
  end
end

Then("the slots from {string} to {string} for {string} should show as {string}") do |start_time, end_time, resource_name, status|
  resource = find_resource(resource_name)
  times = generate_slots(start_time, end_time)
  times.each do |t|
    slot = find_slot(resource, t)
    expect(slot).to have_content(status)
  end
end

Then("the slots from {string} to {string} for {string} should be disabled") do |start_time, end_time, resource_name|
  resource = find_resource(resource_name)
  times = generate_slots(start_time, end_time)
  times.each do |t|
    slot = find_slot_checkbox(resource, t)
    expect(slot).to be_disabled
  end
end

Then("the slots from {string} to {string} for {string} should be enabled") do |start_time, end_time, resource_name|
  resource = find_resource(resource_name)
  times = generate_slots(start_time, end_time)
  times.each do |t|
    slot = find_slot_checkbox(resource, t)
    expect(slot).not_to be_disabled
  end
end

Then("I should not be able to check the {string} slot for {string}") do |time, resource_name|
  resource = find_resource(resource_name)
  slot = find_slot_checkbox(resource, time)
  expect(slot).to be_disabled
  expect { slot.check }.to raise_error(Capybara::ElementNotFound)
end

Then("I should be able to check the {string} slot for {string}") do |time, resource_name|
  resource = find_resource(resource_name)
  slot = find_slot_checkbox(resource, time)
  expect(slot).not_to be_disabled
  slot.check
  expect(slot).to be_checked
end

Then("I should see the booking summary for {string}:") do |resource_name, table|
  within(find_element_by_name(resource_name)) do
    table.rows_hash.each do |key, value|
      expect(page).to have_content(value)
    end
  end
end

Then("I should see the cost {string} for {string}") do |cost, resource_name|
  within(find_element_by_name(resource_name)) do
    expect(page).to have_content(cost)
  end
end

Then("I should see the error {string} for {string}") do |error, resource_name|
  within(find_element_by_name(resource_name)) do
    expect(page).to have_content(error)
  end
end

Then("the {string} button should be disabled for {string}") do |button_text, resource_name|
  within(find_element_by_name(resource_name)) do
    expect(page).to have_button(button_text, disabled: true)
  end
end

Then("the room {string} should show {string}") do |room_name, indicator|
  within(find_element_by_name(room_name)) do
    expect(page).to have_content(indicator)
  end
end

Then("the slots from {string} to {string} for {string} should be available") do |start_time, end_time, resource_name|
  step "the slots from \"#{start_time}\" to \"#{end_time}\" for \"#{resource_name}\" should show as \"Available\""
end

# Helper to find a slot element (checkbox or cell)
def find_slot(resource, time)
  find(:xpath, "//div[@data-resource-id='#{resource.id}' and @data-time='#{time}']")
end

def find_slot_checkbox(resource, time)
  find(:xpath, "//input[@type='checkbox' and @data-resource-id='#{resource.id}' and @data-time='#{time}']")
end
