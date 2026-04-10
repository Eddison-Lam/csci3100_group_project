# db/migrate/20260411000002_initialize_cuhk_departments_and_resources.rb
class InitializeCuhkDepartmentsAndResources < ActiveRecord::Migration[8.1]
  def up
    # ==================== 1. Departments (idempotent) ====================
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
      puts "Inserted Department: #{dept.code} (#{dept.name})"
    end

    cse  = Department.find_by!(code: "CSE")
    ee   = Department.find_by!(code: "EE")
    ie   = Department.find_by!(code: "IE")
    chem = Department.find_by!(code: "CHEM")
    anth = Department.find_by!(code: "ANTH")
    reg  = Department.find_by!(code: "REG")

    # ==================== 2. Resources (idempotent + STI 正確 type) ====================
    resources_data = [
      # === ROOMS ===
      { type: "Room", name: "YIA LT1", building: "Yasumoto International Academic Park (YIA)", location: "Ground Floor", capacity: 280, room_type: "Lecture Theatre", department_id: cse.id, description: "YIA 大講堂 1", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 20 },
      { type: "Room", name: "CYT LT1A", building: "Cheng Yu Tung Building (CYT)", location: "2/F", capacity: 150, room_type: "Lecture Theatre", department_id: ee.id, description: "CYT Lecture Theatre 1A", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: true, min_slots_per_booking: 1, max_slots_per_booking: 16 },
      { type: "Room", name: "LSK LT6", building: "Lee Shau Kee Building (LSK)", location: "1/F", capacity: 120, room_type: "Lecture Theatre", department_id: ie.id, description: "LSK Lecture Theatre 6", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 12 },
      { type: "Room", name: "SWC LT", building: "Shaw College", location: "Shaw College Lecture Theatre", capacity: 180, room_type: "Lecture Theatre", department_id: reg.id, description: "Shaw College Lecture Theatre（全校共用）", is_active: true, advance_booking_days: 14, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 20 },
      { type: "Room", name: "CHEM Lab 301", building: "Science Centre", location: "3/F", capacity: 40, room_type: "Laboratory", department_id: chem.id, description: "Chemistry Laboratory 301", is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: true, min_slots_per_booking: 4, max_slots_per_booking: 12 },

      # === EQUIPMENT ===
      { type: "Equipment", name: "Portable Projector", description: "BenQ 高亮度投影機", quantity: 12, department_id: reg.id, is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 50.0, requires_approval: true, min_slots_per_booking: 1, max_slots_per_booking: 8 },
      { type: "Equipment", name: "Wireless Microphone Set", description: "手持 + 領夾式無線麥克風組", quantity: 8, department_id: reg.id, is_active: true, advance_booking_days: 7, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 30.0, requires_approval: false, min_slots_per_booking: 1, max_slots_per_booking: 4 },
      { type: "Equipment", name: "Laptop (MacBook Pro)", description: "15吋 MacBook Pro M3", quantity: 20, department_id: cse.id, is_active: true, advance_booking_days: 3, operating_start_slot: 16, operating_end_slot: 44, price_per_unit: 0.0, requires_approval: true, min_slots_per_booking: 1, max_slots_per_booking: 2 }
    ]

    resources_data.each do |data|
      resource = Resource.find_or_create_by!(name: data[:name], department_id: data[:department_id]) do |r|
        r.assign_attributes(data)
      end
      puts "Inserted Resource: #{resource.name} (#{resource.type})"
    end

    puts "\nCUHK init:\n   Departments: #{Department.count}\n   Resources: #{Resource.count}"
  end

  def down
    Resource.destroy_all
    Department.where(code: %w[CSE EE IE CHEM ANTH REG]).destroy_all
  end
end
