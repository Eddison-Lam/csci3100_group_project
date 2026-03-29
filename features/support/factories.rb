# features/support/factories.rb
FactoryBot.define do
  # User factories
  factory :user do
    sequence(:email) { |n| "user#{n}@cuhk.edu.hk" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :student do
      role { :student }
    end

    trait :admin do
      role { :admin }
      activated { true }
    end

    trait :superadmin do
      role { :superadmin }
    end
  end

  # Department factory
  factory :department do
    sequence(:name) { |n| "Department #{n}" }
    sequence(:code) { |n| "DEPT#{n}" }
  end

  # Room factory
  factory :room do
    sequence(:name) { |n| "Room #{n}" }
    association :department
    building { "Main Building" }
    room_type { "Meeting Room" }
    location { "1/F" }
    capacity { 20 }
    max_slots_per_booking { 8 }
    price_per_unit { 0.0 }
    requires_approval { false }
    active { true }

    trait :paid do
      price_per_unit { 100.0 }
    end

    trait :requires_approval do
      requires_approval { true }
    end
  end

  # Equipment factory
  factory :equipment do
    sequence(:name) { |n| "Equipment #{n}" }
    association :department
    equipment_type { "AV Equipment" }
    quantity { 5 }
    price_per_unit { 0.0 }
    active { true }
  end

  # Booking factory
  factory :booking do
    association :user, :student
    association :resource, factory: :room
    date { Date.current + 1.day }
    start_time { "10:00" }
    end_time { "12:00" }
    status { :confirmed }
    purpose { "Test booking" }

    trait :pending do
      status { :pending }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :rejected do
      status { :rejected }
      rejection_reason { "Test rejection" }
    end

    trait :with_cost do
      after(:build) do |booking|
        booking.total_cost = booking.resource.price_per_unit * booking.slots_count
      end
    end
  end

  # BookingLock factory (if you have this model)
  factory :booking_lock do
    association :user
    association :resource, factory: :room
    date { Date.current + 1.day }
    start_time { "10:00" }
    end_time { "12:00" }
    expires_at { 5.minutes.from_now }
  end
end