# Extend the existing web_steps with common navigation and content checks

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