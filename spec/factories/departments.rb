FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Department #{n}" }
    sequence(:code) { |n| "DEPT#{n}" }
    is_active { true }
  end
end
