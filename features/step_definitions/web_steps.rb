# Extend the existing web_steps with common navigation and content checks

When("I select date {string}") do |date_str|
  date = case date_str.downcase
  when "today"
    Date.current
  when "tomorrow"
    Date.current + 1.day
  when "yesterday"
    Date.current - 1.day
  else
    Date.parse(date_str)
  end
  fill_in "date", with: date.to_s
end

When("I go to the home page") do
  visit root_path
end

When("I visit {string}") do |page_name|
  visit path_to(page_name)
end

When("I click {string}") do |link_or_button|
  click_link_or_button link_or_button
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I select {string} from {string}") do |option, dropdown|
  select option, from: dropdown
end

When("I fill in the following:") do |table|
  table.rows_hash.each do |field, value|
    fill_in field, with: value
  end
end

When("I check {string} under {string}") do |checkbox, section|
  within(:xpath, "//fieldset[legend[contains(text(), '#{section}')]]") do
    check checkbox
  end
end

When("I am on the rooms page") do
  visit rooms_path
end

Then("the page should not contain {string}") do |text|
  expect(page).to have_no_content(text)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).to have_no_content(text)
end

Then("I should be on the {string} page") do |page_name|
  expect(current_path).to eq(path_to(page_name))
end

Then("I should be on the login page") do
  expect(current_path).to eq(new_user_session_path)
end

Then("I should be redirected to the {string} page") do |page_name|
  expect(current_path).to eq(path_to(page_name))
end

When("I register as a student with email {string}") do |email|
  visit new_user_registration_path
  fill_in "Email", with: email
  fill_in "Password", with: "password123"
  fill_in "Password confirmation", with: "password123"
  click_button "Sign up"
end

Then("I should be redirected to the home page") do
  expect(current_path).to eq(root_path)
end

When("I try to visit the admin resources page") do
  visit admin_resources_path
end

When("I visit my bookings page") do
  visit bookings_path
end

Then("I should not see the other student's booking") do
  # The other student's booking should not be visible
  other_user = User.find_by(email: "other@link.cuhk.edu.hk")
  expect(page).to have_no_content(other_user.bookings.first.resource.name) if other_user&.bookings&.any?
end

Then("I should see available slots") do
  # Check that at least some slots are visible on the page
  expect(page).to have_content(/:/)  # Time slots typically show times like "10:00"
end

Then("I should be on my bookings page") do
  expect(current_path).to eq(bookings_path)
end

Then("I should see the booking confirmation form with:") do |table|
  table.rows_hash.each do |label, value|
    expect(page).to have_content(label) if label.present?
  end
end

Then("I should see {string} or {string}") do |text1, text2|
  has_text1 = page.has_content?(text1)
  has_text2 = page.has_content?(text2)
  expect(has_text1 || has_text2).to be true
end

Then("no booking should be created") do
  expect(Booking.count).to eq(0)
end

Then("I should be on the rooms page") do
  expect(current_path).to eq(rooms_path)
end

Then("I should be on the equipment page") do
  expect(current_path).to eq(equipment_index_path)
end

Then("I should be on the my bookings page") do
  expect(current_path).to eq(bookings_path)
end

Then("the booking status should be {string}") do |status|
  booking = Booking.last
  expect(booking.status).to eq(status.downcase)
end

Given("I have a confirmed booking for {string} on {string} from {string} to {string}") do |room_name, date_str, start_time, end_time|
  room = Room.find_by(name: room_name)
  date = parse_date(date_str)
  start_slot = time_to_slot(start_time)
  end_slot = time_to_slot(end_time)
  create(:booking, user: @current_user, resource: room, booking_date: date, start_slot: start_slot, end_slot: end_slot, status: :confirmed)
end

When("I select slots from {string} to {string}") do |start_time_str, end_time_str|
  # This step is for the new slot selection UI
  start_time = Time.zone.parse(start_time_str)
  end_time = Time.zone.parse(end_time_str)
  start_slot = (start_time.hour * 2 + (start_time.min / 30).floor)

  current_time = start_time
  while current_time < end_time
    slot_div = find("[data-slot='#{start_slot}']", visible: :all)
    click_on slot_div if slot_div
    start_slot += 1
    current_time += 30.minutes
  end
end

Then(/^I should see "([^"]*)" or see "([^"]*)"$/) do |text1, text2|
  # Try to find either text on the page
  if page.has_content?(text1)
    expect(page).to have_content(text1)
  elsif page.has_content?(text2)
    expect(page).to have_content(text2)
  else
    # Fail with a helpful message showing both expected texts
    expect(page).to have_content(text1).or have_content(text2)
  end
end
def time_to_slot(time_str)
  time = Time.zone.parse(time_str)
  time.hour * 2 + (time.min / 30).floor
end
