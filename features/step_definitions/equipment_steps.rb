Given("the following equipment exists:") do |table|
  table.hashes.each do |row|
    department = Department.find_by(name: row["department"]) || create(:department, name: row["department"])
    create(:equipment,
      name: row["name"],
      department: department,
      quantity: row["quantity"].to_i,
      price_per_unit: row["price_per_unit"].to_f
    )
  end
end

Given("the equipment {string} has 0 available quantity today") do |equipment_name|
  equipment = Equipment.find_by(name: equipment_name)
  future_date = Date.today + 1.day
  user = User.first || create(:user)
  # Create bookings to exhaust availability
  equipment.quantity.times do |i|
    create(:booking,
      resource: equipment,
      booking_date: future_date,
      status: :confirmed,
      start_slot: 16,
      end_slot: 18,
      user: user
    )
  end
end

Given("the equipment {string} is inactive") do |equipment_name|
  equipment = Equipment.find_by(name: equipment_name)
  equipment.update!(is_active: false)
end

Given("an equipment {string} exists in {string} with price_per_unit {float}") do |equipment_name, dept_name, price|
  department = Department.find_by(name: dept_name) || create(:department, name: dept_name)
  create(:equipment,
    name: equipment_name,
    department: department,
    price_per_unit: price,
    quantity: 1   # default quantity
  )
end
