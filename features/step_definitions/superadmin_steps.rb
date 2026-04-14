Given("the booking lock timeout is {int} minutes") do |minutes|
  # Assume a system setting model
  Setting.find_or_create_by(key: "booking_lock_timeout").update(value: minutes)
end

When("I visit the admin settings page") do
  visit admin_settings_path
end

When("I change the lock timeout to {int} minutes") do |minutes|
  step "I visit the admin settings page"
  step "I fill in \"Booking lock timeout (minutes)\" with \"#{minutes}\""
  step "I click \"Save Settings\""
end

When("a student creates a new booking lock") do
  @student = create(:user, :student)
  login_as(@student, scope: :user)
  step "I visit the rooms page for \"tomorrow\""
  step "I select slots from \"10:00\" to \"12:00\" for \"Room X\""
  step "I click \"Book This Room\" for \"Room X\""
end

Then("the booking lock timeout should be {int} minutes") do |minutes|
  expect(Setting.find_by(key: "booking_lock_timeout").value.to_i).to eq(minutes)
end

Then("the lock should expire in {int} minutes") do |minutes|
  lock = BookingLock.last
  expect(lock.expires_at).to be_within(1.second).of(Time.current + minutes.minutes)
end
