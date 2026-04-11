# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
puts "Start init CUHK Departments & Resources..."

# ==================== 1. Departments ====================
departments_data = [
  { code: "CSE",  name: "Department of Computer Science and Engineering", is_active: true },
  { code: "EE",   name: "Department of Electronic Engineering", is_active: true },
  { code: "IE",   name: "Department of Information Engineering", is_active: true },
  { code: "CHEM", name: "Department of Chemistry", is_active: true },
  { code: "ANTH", name: "Department of Anthropology", is_active: true },
  { code: "REG",  name: "Registry / Central Facilities", is_active: true }
]

departments_data.each do |data|
  dept = Department.find_or_create_by!(code: data[:code]) do |d|
    d.name = data[:name]
    d.is_active = data[:is_active]
  end
  puts "Inserted Department: #{dept.code} - #{dept.name}"
end

cse  = Department.find_by!(code: "CSE")
ee   = Department.find_by!(code: "EE")
ie   = Department.find_by!(code: "IE")
chem = Department.find_by!(code: "CHEM")
anth = Department.find_by!(code: "ANTH")
reg  = Department.find_by!(code: "REG")

# ==================== 2. Resources ====================
resources_data = [
  # === ROOMS ===
  { type: "Room", name: "YIA LT1", building: "Yasumoto International Academic Park (YIA)", location: "Ground Floor", capacity: 280, room_type: "Lecture Theatre", department_id: cse.id, description: "YIA 大講堂 1", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 20 },
  { type: "Room", name: "CYT LT1A", building: "Cheng Yu Tung Building (CYT)", location: "2/F", capacity: 150, room_type: "Lecture Theatre", department_id: ee.id, description: "CYT Lecture Theatre 1A", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 16 },
  { type: "Room", name: "LSK LT6", building: "Lee Shau Kee Building (LSK)", location: "1/F", capacity: 120, room_type: "Lecture Theatre", department_id: ie.id, description: "LSK Lecture Theatre 6", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 12 },
  { type: "Room", name: "SWC LT", building: "Shaw College", location: "Shaw College Lecture Theatre", capacity: 180, room_type: "Lecture Theatre", department_id: reg.id, description: "Shaw College Lecture Theatre（全校共用）", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 20 },
  { type: "Room", name: "CHEM Lab 301", building: "Science Centre", location: "3/F", capacity: 40, room_type: "Laboratory", department_id: chem.id, description: "Chemistry Laboratory 301", is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 4, max_slots_per_booking: 12 },

  # === EQUIPMENT ===
  { type: "Equipment", name: "Portable Projector", description: "BenQ 高亮度投影機（可外借）", quantity: 12, department_id: reg.id, is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 50.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 8 },
  { type: "Equipment", name: "Wireless Microphone Set", description: "手持 + 領夾式無線麥克風組", quantity: 8, department_id: reg.id, is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 30.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 4 },
  { type: "Equipment", name: "Laptop (MacBook Pro)", description: "15吋 MacBook Pro M3（會議室借用）", quantity: 20, department_id: cse.id, is_active: true, advance_booking_days: 3, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 2 },

  # === 收費 ROOMS ===
  { type: "Room", name: "SHB Multi-Purpose Hall", building: "Student Hall B (SHB)", location: "G/F", capacity: 200, room_type: "Multi-Purpose Hall", department_id: reg.id, description: "學生會堂多用途禮堂，適合舉辦大型活動、典禮、表演等", is_active: true, advance_booking_days: 30, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 500.0, requires_approval: false, min_slots_per_booking: 4, max_slots_per_booking: 20 },
  { type: "Room", name: "UCO Meeting Room A", building: "University Administration Building", location: "3/F", capacity: 20, room_type: "Meeting Room", department_id: reg.id, description: "高級會議室，配備視訊會議系統及白板", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 200.0, requires_approval: false, min_slots_per_booking: 2, max_slots_per_booking: 8 },
  { type: "Room", name: "YIA Video Studio", building: "Yasumoto International Academic Park (YIA)", location: "4/F", capacity: 10, room_type: "Studio", department_id: ie.id, description: "專業錄影室，配備綠幕、燈光及錄音設備", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 300.0, requires_approval: false, min_slots_per_booking: 2, max_slots_per_booking: 12 },
  { type: "Room", name: "Sports Centre Badminton Court", building: "University Sports Centre", location: "1/F", capacity: 4, room_type: "Sports Facility", department_id: reg.id, description: "羽毛球場（單個場地）", is_active: true, advance_booking_days: 7, operating_start_slot: 18, operating_end_slot: 46, price_per_unit: 80.0, requires_approval: false, min_slots_per_booking: 2, max_slots_per_booking: 6 },
  { type: "Room", name: "CYT Practice Room 201", building: "Cheng Yu Tung Building (CYT)", location: "2/F",  capacity: 8, room_type: "Practice Room", department_id: reg.id, description: "音樂練習室，配備鋼琴", is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 60.0, requires_approval: false, min_slots_per_booking: 2, max_slots_per_booking: 8 },

  # === 收費 EQUIPMENT ===
  { type: "Equipment", name: "Professional Camera (Sony A7S III)", description: "專業全片幅攝影機，含鏡頭組及腳架", quantity: 5, department_id: ie.id, is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 150.0, requires_approval: false, min_slots_per_booking: 4, max_slots_per_booking: 12 },
  { type: "Equipment", name: "VR Headset (Meta Quest 3)", description: "虛擬實境頭戴裝置，適用於教學及研究", quantity: 10, department_id: cse.id, is_active: true, advance_booking_days: 5, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 100.0, requires_approval: false, min_slots_per_booking: 2, max_slots_per_booking: 8 },
  { type: "Equipment", name: "Podcast Recording Kit", description: "Podcast 錄音套組（含麥克風、混音器、監聽耳機）", quantity: 6, department_id: reg.id, is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 120.0, requires_approval: false, min_slots_per_booking: 2, max_slots_per_booking: 10 },
  { type: "Equipment", name: "3D Printer (Ultimaker S5)", description: "專業級 3D 列印機（材料費另計）", quantity: 3, department_id: cse.id, is_active: true, advance_booking_days: 10, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 200.0, requires_approval: false, min_slots_per_booking: 4, max_slots_per_booking: 16 },
  { type: "Equipment", name: "LED Light Panel Set", description: "專業 LED 攝影燈組（3燈含燈架）", quantity: 8, department_id: reg.id, is_active: true, advance_booking_days: 5, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 80.0, requires_approval: false, min_slots_per_booking: 2, max_slots_per_booking: 8 },
  { type: "Equipment", name: "Portable PA System", description: "行動式擴音系統，適合戶外活動使用", quantity: 4, department_id: reg.id, is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 150.0, requires_approval: false, min_slots_per_booking: 4,  max_slots_per_booking: 12 }
]

resources_data.each do |data|
  resource = Resource.find_or_create_by!(name: data[:name], department_id: data[:department_id]) do |r|
    r.assign_attributes(data)
  end
  puts "Inserted Resource: #{resource.name} (#{resource.type})"
end

puts "\n🎉 CUHK Seed success! \n   Departments: #{Department.count}\n   Resources: #{Resource.count} (Rooms: #{Room.count} | Equipments: #{Equipment.count})"
