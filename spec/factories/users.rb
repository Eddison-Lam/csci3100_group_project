FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "student#{n}@link.cuhk.edu.hk" }
    password { "password123" }
    role { :student }

    trait :student do
      sequence(:email) { |n| "student#{n}@link.cuhk.edu.hk" }
      role { :student }
    end

    trait :admin do
      sequence(:email) { |n| "staff#{n}@cuhk.edu.hk" }
      role { :admin }
      department
    end

    trait :superadmin do
      sequence(:email) { |n| "super#{n}@cuhk.edu.hk" }
      role { :superadmin }
      department
    end
  end
end
