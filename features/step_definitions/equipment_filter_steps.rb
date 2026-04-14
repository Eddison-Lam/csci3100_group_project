When("I visit the equipment page for {string}") do |date_str|
  date = parse_date(date_str)
  visit equipment_index_path(date: date)
end

When("I visit the equipment page") do
  visit equipment_index_path
end

When("I check {string} under {string}") do |checkbox, section|
  within(:xpath, "//fieldset[legend[contains(text(), '#{section}')]]") do
    check checkbox
  end
end

Then("the equipment {string} should display {string}") do |equipment_name, text|
  within(find_element_by_name(equipment_name)) do
    expect(page).to have_content(text)
  end
end

Then("I should see {string} for {string}") do |text, equipment_name|
  within(find_element_by_name(equipment_name)) do
    expect(page).to have_content(text)
  end
end

Then("the equipment {string} should show {string}") do |equipment_name, status|
  within(find_element_by_name(equipment_name)) do
    expect(page).to have_content(status)
  end
end

Then("I should not be able to book {string}") do |equipment_name|
  within(find_element_by_name(equipment_name)) do
    expect(page).to have_no_button("Book")
  end
end

Then("I should see the booking summary for {string}:") do |equipment_name, table|
  within(find_element_by_name(equipment_name)) do
    table.rows_hash.each do |key, value|
      expect(page).to have_content(value)
    end
  end
end

Then("I should see the booking cost breakdown:") do |table|
  table.rows_hash.each do |label, value|
    expect(page).to have_content("#{label}: #{value}")
  end
end
