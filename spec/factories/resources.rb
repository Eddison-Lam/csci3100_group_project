FactoryBot.define do
  factory :resource do
    sequence(:name) { |n| "Resource #{n}" }
    type { "Room" }
    department
    is_active { true }
    building { "Science Centre" }
    location { "2/F Room 201" }
    operating_start_slot { 16 }
    operating_end_slot { 44 }

    trait :room do
      type { "Room" }
      building { "Science Centre" }
      location { "2/F Room 201" }
      capacity { 30 }
    end

    trait :equipment do
      type { "Equipment" }
      building { nil }
      location { nil }
      quantity { 5 }
    end
  end
end
