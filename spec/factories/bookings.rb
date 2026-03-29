FactoryBot.define do
  factory :booking do
    user
    resource
    booking_date { 1.day.from_now.to_date }
    start_slot { 16 }
    end_slot { 18 }
    status { :confirmed }
  end
end
