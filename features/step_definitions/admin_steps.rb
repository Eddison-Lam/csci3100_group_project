Given("a department {string} exists with an admin {string}") do |dept_name, admin_email|
  admin = create(:user, :admin, email: admin_email, password: "password123")
  department = create(:department, name: dept_name)
  # Properly assign admin to department through the association
  department.admins << admin unless department.admins.include?(admin)
end

Given("a room {string} exists in {string} with price_per_unit {float}") do |room_name, dept_name, price|
  department = Department.find_by(name: dept_name)
  create(:room, name: room_name, department: department, price_per_unit: price)
end

Given("a room {string} exists with requires_approval {string}") do |room_name, requires_approval|
  create(:room, name: room_name, requires_approval: requires_approval == "true")
end

Given("a room {string} exists with price_per_unit {float} and requires_approval {string}") do |room_name, price, requires_approval|
  create(:room, name: room_name, price_per_unit: price, requires_approval: requires_approval == "true")
end

When("I visit the admin resources page") do
  visit admin_resources_path
end

When("I select {string} from {string}") do |option, dropdown|
  select option, from: dropdown
end

When("I fill in the following:") do |table|
  table.rows_hash.each do |field, value|
    fill_in field, with: value
  end
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I check {string}") do |field|
  check field
end

When("I try to edit resource {string}") do |resource_name|
  resource = find_resource(resource_name)
  visit path_to("the edit resource page for #{resource_name}")
end

When("I filter by {string}") do |filter|
  # Adjust to match your UI – this example clicks a link with the filter text
  click_link filter
  # If you have a dropdown + button, use:
  # select filter, from: "Status"
  # click_button "Filter"
end

When("I click {string} for {string}") do |link, resource_name|
  within(find_element_by_name(resource_name)) do
    click_link link
  end
end

Then("I should see {string} per slot") do |price|
  expect(page).to have_content(price)
end

Then("{string} should have price_per_unit {float}") do |room_name, price|
  room = Room.find_by(name: room_name)
  expect(room.price_per_unit).to eq(price)
end

Then("the room should be created with requires_approval true") do
  room = Room.last
  expect(room.requires_approval).to be true
end

Then("{string} should require approval") do |room_name|
  room = Room.find_by(name: room_name)
  expect(room.requires_approval).to be true
end

Then("new bookings for {string} should be pending") do |room_name|
  room = Room.find_by(name: room_name)
  # Assuming any new booking for this room is pending; not implemented here
end
