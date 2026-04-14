# --- Givens ---
Given("a confirmed booking exists for {string} on {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  start_slot = time_to_slot(start_time)
  end_slot = time_to_slot(end_time)
  booking_user = @current_user || create(:user)
  create(:booking, user: booking_user, resource: resource, booking_date: date, start_slot: start_slot, end_slot: end_slot, status: :confirmed)
end

Given("a pending booking exists for {string} on {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  start_slot = time_to_slot(start_time)
  end_slot = time_to_slot(end_time)
  booking_user = @current_user || create(:user)
  create(:booking, user: booking_user, resource: resource, booking_date: date, start_slot: start_slot, end_slot: end_slot, status: :pending_payment)
end

Given("a cancelled booking exists for {string} on {string} from {string} to {string}") do |resource_name, date_str, start_time, end_time|
  date = parse_date(date_str)
  resource = find_resource(resource_name)
  start_slot = time_to_slot(start_time)
  end_slot = time_to_slot(end_time)
  booking_user = @current_user || create(:user)
  create(:booking, user: booking_user, resource: resource, booking_date: date, start_slot: start_slot, end_slot: end_slot, status: :cancelled)
end

# --- Thens ---
Then("no booking should be created") do
  expect(Booking.count).to eq(0)
end

# --- Helpers ---
def find_resource(name)
  Room.find_by(name: name) || Equipment.find_by(name: name) || (raise "Resource #{name} not found")
end
