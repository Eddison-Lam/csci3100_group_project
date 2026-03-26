FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "student#{n}@link.cuhk.edu.hk" }
    password { "password123" }

    trait :admin do
      sequence(:email) { |n| "staff#{n}@cuhk.edu.hk" }
      department
    end

    trait :superadmin do
      sequence(:email) { |n| "super#{n}@cuhk.edu.hk" }
      role { :superadmin }
      department
    end
  end
end
