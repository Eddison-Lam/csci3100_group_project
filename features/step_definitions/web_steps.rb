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

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).to have_no_content(text)
end

Then("I should be on the {string} page") do |page_name|
  expect(current_path).to eq(path_to(page_name))
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