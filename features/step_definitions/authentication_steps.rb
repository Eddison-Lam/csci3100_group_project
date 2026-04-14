Given("I am on the login page") do
  visit new_user_session_path
end

Given("I am on the registration page") do
  visit new_user_registration_path
end

Given("a student {string} exists") do |email|
  create(:user, :student, email: email, password: "password123")
end

Given("an activated admin {string} exists in department {string}") do |email, dept_name|
  department = Department.find_by(name: dept_name) || create(:department, name: dept_name)
  admin = create(:user, :admin, email: email, password: "password123", department: department)
end

Given("I am logged in as a student") do
  @current_user = create(:user, :student, password: "password123")
  login_as(@current_user, scope: :user)
end

Given("I am logged in as a superadmin") do
  @current_user = create(:user, :superadmin, password: "password123")
  login_as(@current_user, scope: :user)
end

Given("I am logged in as admin {string}") do |email|
  @current_user = User.find_by(email: email) || create(:user, :admin, email: email, password: "password123")
  login_as(@current_user, scope: :user)
end

When("I fill in the following:") do |table|
  table.rows_hash.each do |field, value|
    fill_in field, with: value
  end
end

Then("my role should be {string}") do |role|
  expect(User.last.role).to eq(role)
end

Then("I should not have a department assigned") do
  expect(User.last.department).to be_nil
end

Then("I should not be signed in") do
  expect(page).to have_no_css(".user-greeting") # adjust as needed
end
