# --- Givens ---
Given("a confirmed booking exists for {string} on {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  create(:booking, resource: resource, date: date, start_time: start_time, end_time: end_time, status: :confirmed)
end

Given("a pending booking exists for {string} on {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  create(:booking, resource: resource, date: date, start_time: start_time, end_time: end_time, status: :pending)
end

Given("a cancelled booking exists for {string} on {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  create(:booking, resource: resource, date: date, start_time: start_time, end_time: end_time, status: :cancelled)
end

Given("a rejected booking exists for {string} on {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  create(:booking, resource: resource, date: date, start_time: start_time, end_time: end_time, status: :rejected)
end

Given("I have a confirmed booking for {string} {string} {string}-{string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  create(:booking, user: @current_user, resource: resource, date: date, start_time: start_time, end_time: end_time, status: :confirmed)
end

Given("I have a pending booking for {string} {string} {string}-{string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  create(:booking, user: @current_user, resource: resource, date: date, start_time: start_time, end_time: end_time, status: :pending)
end

Given("I have a cancelled booking for {string}") do |resource_name|
  resource = find_resource(resource_name)
  create(:booking, user: @current_user, resource: resource, status: :cancelled)
end

Given("I have a rejected booking for {string} with reason {string}") do |resource_name, reason|
  resource = find_resource(resource_name)
  create(:booking, user: @current_user, resource: resource, status: :rejected, rejection_reason: reason)
end

Given("I have a rejected booking for {string}") do |resource_name|
  resource = find_resource(resource_name)
  create(:booking, user: @current_user, resource: resource, status: :rejected)
end

Given("I have the following bookings:") do |table|
  table.hashes.each do |row|
    resource = find_resource(row["resource"])
    date = parse_date(row["date"])
    start_time = row["start"]
    end_time = row["end"]
    status = row["status"].downcase.to_sym
    total_cost = row["total_cost"].to_f
    create(:booking,
      user: @current_user,
      resource: resource,
      date: date,
      start_time: start_time,
      end_time: end_time,
      status: status,
      total_cost: total_cost
    )
  end
end

Given("a student {string} has a pending booking for {string}") do |student_name, resource_name|
  student = create(:user, name: student_name, email: "#{student_name}@example.com", role: :student)
  resource = find_resource(resource_name)
  create(:booking, user: student, resource: resource, status: :pending)
end

Given("a booking exists for {string} with status {string}") do |resource_name, status|
  resource = find_resource(resource_name)
  create(:booking, resource: resource, status: status.downcase.to_sym)
end

Given("{string} has a booking") do |email|
  user = User.find_by(email: email) || create(:user, email: email, role: :student)
  # Use an existing room or create a default one
  resource = Room.first || create(:room, name: "Default Room")
  create(:booking,
    user: user,
    resource: resource,
    date: Date.current + 1.day,
    start_time: "10:00",
    end_time: "12:00",
    status: :confirmed
  )
end

When("I successfully book {string} for {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  visit resource_booking_path(resource, date: date) # adjust path
  select_slots(resource, start_time, end_time)
  click_button "Book This Room" # or "Book This Equipment"
  fill_in "Purpose", with: "Test booking"
  click_button "Confirm Booking"
end

When("I have a pending booking for {string} tomorrow {string}-{string}") do |resource_name, start_time, end_time|
  step "I have a pending booking for \"#{resource_name}\" \"tomorrow\" \"#{start_time}\"-\"#{end_time}\""
end

When("I click {string} for {string}") do |link, context|
  # Find link within a specific context (e.g., booking row, room card)
  within(find_element_by_name(context)) do
    click_link link
  end
end

When("I click {string} for the booking by {string}") do |action, student_name|
  booking = Booking.joins(:user).find_by(users: { name: student_name })
  within("#booking_#{booking.id}") do
    click_link action
  end
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I check {string}") do |field|
  check field
end

When("I uncheck the {string} slot for {string}") do |time, resource_name|
  resource = find_resource(resource_name)
  slot = find_slot_checkbox(resource, time)
  uncheck slot[:id]
end

When("I refresh the page") do
  visit current_path
end

When("I cancel that booking") do
  # Assumes we're on my bookings page and have a booking in context
  click_link "Cancel", match: :first
end

When("another student visits the rooms page for {string}") do |date_str|
  # Simulate another user by creating a new session or just visiting as a different user
  @other_user = create(:user, :student)
  login_as(@other_user, scope: :user)
  visit rooms_path(date: parse_date(date_str))
end

When("another user books {string} on {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  @other_user ||= create(:user, :student)
  original_user = @current_user
  login_as(@other_user, scope: :user)
  step "I successfully book \"#{resource_name}\" for \"#{date_str}\" from \"#{start_time}\" to \"#{end_time}\""
  login_as(original_user, scope: :user) if original_user
end

When("I click {string} for that booking") do |link|
  within(".booking", match: :first) do   # Adjust selector to match your booking container
    click_link_or_button(link)
  end
end

When("I click on the booking") do
  find(".booking a", match: :first).click   # Adjust selector to your booking detail link
end

Then("the booking status should be {string}") do |status|
  booking = Booking.last
  expect(booking.status).to eq(status.downcase.to_sym)
end

Then("I should see the booking cost {string}") do |cost|
  expect(page).to have_content(cost)
end

Then("I should see the booking cost breakdown:") do |table|
  table.rows_hash.each do |label, value|
    expect(page).to have_content("#{label}: #{value}")
  end
end

Then("{string} should have price_per_unit {float}") do |room_name, price|
  room = Room.find_by(name: room_name)
  expect(room.price_per_unit).to eq(price)
end

Then("I should see {string} with cost {string}") do |resource_name, cost|
  within(find_element_by_name(resource_name)) do
    expect(page).to have_content(cost)
  end
end

Then("I should see the booking details:") do |table|
  table.rows_hash.each do |label, value|
    expect(page).to have_content("#{label}: #{value}")
  end
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).to have_no_content(text)
end

Then("the booking should not be created") do
  expect(Booking.count).to eq(0) # or compare to previous count
end

Then("I should receive a confirmation email") do
  # Assuming using ActionMailer with deliveries
  expect(ActionMailer::Base.deliveries.last.to).to include(@current_user.email)
end

Then("I should not receive a confirmation email yet") do
  expect(ActionMailer::Base.deliveries).to be_empty
end

Then("{string} should appear before {string}") do |text1, text2|
  expect(page.body.index(text1)).to be < page.body.index(text2)
end

Then("I should see {string} in the {string} tab") do |content, tab_name|
  within(".tab-pane.active") do
    expect(page).to have_content(content)
  end
end

Then("I should not see {string} button for that booking") do |button_text|
  within(".booking", match: :first) do
    expect(page).to have_no_button(button_text)
    expect(page).to have_no_link(button_text)
  end
end

Then("I should see the booking confirmation form with:") do |table|
  table.rows_hash.each do |label, value|
    expect(page).to have_content("#{label}: #{value}")
  end
end

# Helper to find resource (room or equipment) by name
def find_resource(name)
  Room.find_by(name: name) || Equipment.find_by(name: name) || (raise "Resource #{name} not found")
end

def find_element_by_name(name)
  # Find a container that likely holds the resource info (e.g., a card or row)
  find(:xpath, "//*[contains(text(), '#{name}')]/ancestor::div[contains(@class, 'card') or contains(@class, 'row')]")
end

def select_slots(resource, start_time, end_time)
  # Updated for clickable slot divs
  times = generate_slots(start_time, end_time)
  times.each { |t| click_on t }
end

def generate_slots(start_str, end_str)
  start_t = Time.zone.parse(start_str)
  end_t = Time.zone.parse(end_str)
  slots = []
  while start_t < end_t
    slots << start_t.strftime("%H:%M")
    start_t += 30.minutes
  end
  slots
end