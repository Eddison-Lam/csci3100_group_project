#!/usr/bin/env ruby
require_relative 'config/environment'

# Find a department with resources
dept = Department.find_by(name: "Department of Computer Science and Engineering")
puts "Selected department: #{dept.name} (ID: #{dept.id})"

# Create an admin user for this department
user = User.create!(
  email: "deptadmin@cuhk.edu.hk",
  password: "password123",
  role: :admin,
  department: dept
)
puts "Created admin user: #{user.email} with department #{user.department.name}"

# Test the filtering by simulating what the controller does
puts "\nTesting room filtering:"
rooms_all = Room.all.count
rooms_filtered = user.superadmin? ? Room.all.count : Room.where(department_id: user.department_id).count
puts "Total rooms: #{rooms_all}, Filtered for user: #{rooms_filtered}"

puts "\nTesting equipment filtering:"
equipment_all = Equipment.all.count
equipment_filtered = user.superadmin? ? Equipment.all.count : Equipment.where(department_id: user.department_id).count
puts "Total equipment: #{equipment_all}, Filtered for user: #{equipment_filtered}"

puts "\nTesting booking filtering for today's date:"
today = Date.current
bookings_room_all = Booking.joins(:resource).where(booking_date: today, resources: { type: "Room" }).count
bookings_room_filtered = Booking.joins(:resource).where(booking_date: today, resources: { type: "Room", department_id: user.department_id }).count unless user.superadmin?
bookings_room_filtered ||= bookings_room_all
puts "Total room bookings today: #{bookings_room_all}, Filtered: #{bookings_room_filtered}"

# Clean up
user.destroy
puts "\nTest user deleted."
