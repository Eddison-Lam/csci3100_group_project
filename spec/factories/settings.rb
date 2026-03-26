FactoryBot.define do
  factory :setting do
    sequence(:key) { |n| "test_key_#{n}" }
    value { "10" }
    value_type { "string" }
  end
end
