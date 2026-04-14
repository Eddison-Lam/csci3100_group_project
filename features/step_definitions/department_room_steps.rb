Given("a department {string} with admin {string}") do |dept_name, admin_email|
  admin = create(:user, :admin, email: admin_email, password: "password123")
  department = create(:department, name: dept_name)
  # Properly assign admin to department through the association
  department.admins << admin unless department.admins.include?(admin)
end

Given("a department {string} exists") do |dept_name|
  create(:department, name: dept_name)
end

Given("the following departments exist:") do |table|
  table.hashes.each do |row|
    create(:department, name: row["name"], code: row["code"])
  end
end

Given("a room {string} exists in {string}") do |room_name, dept_name|
  department = Department.find_by(name: dept_name)
  create(:room, name: room_name, department: department)
end

Given('a room {string} exists with price_per_unit {float}') do |room_name, price|
  department = Department.first || create(:department, name: "Default Department")
  create(:room, name: room_name, department: department, price_per_unit: price)
end

Given("a room {string} exists in {string} with:") do |room_name, dept_name, table|
  department = Department.find_by(name: dept_name)
  attributes = table.rows_hash.transform_keys(&:underscore)
  attributes["price_per_unit"] = attributes.delete("price_per_unit").to_f if attributes["price_per_unit"]
  attributes["requires_approval"] = attributes["requires_approval"] == "true"
  create(:room, name: room_name, department: department, **attributes.symbolize_keys)
end

Given("a room {string} exists with requires_approval {string}") do |room_name, requires_approval|
  create(:room, name: room_name, requires_approval: requires_approval == "true")
end

Given("the room {string} is inactive") do |room_name|
  room = Room.find_by(name: room_name)
  room.update!(active: false)
end

Given("a room {string} exists with requires_approval {string} and price_per_unit {float}") do |room_name, requires_approval, price|
  create(:room, name: room_name, requires_approval: requires_approval == "true", price_per_unit: price)
end

Given("the following rooms exist:") do |table|
  table.hashes.each do |row|
    department = Department.find_by(name: row["department"]) || create(:department, name: row["department"])
    attributes = row.except("department").transform_keys(&:underscore)
    # Convert price to float if present
    attributes["price_per_unit"] = attributes["price_per_unit"].to_f if attributes["price_per_unit"]
    # Convert approval flag to boolean if present
    attributes["requires_approval"] = attributes["requires_approval"] == "true" if attributes["requires_approval"]
    create(:room, department: department, **attributes.symbolize_keys)
  end
end

Given("a room {string} exists with requires_approval {string}") do |room_name, requires_approval|
  create(:room, name: room_name, requires_approval: requires_approval == "true")
end
