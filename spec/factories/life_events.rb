FactoryBot.define do
  factory :life_event do
    user
    simulation
    event_type { 0 }
    event_date { 2030 }
    title { "旅行" }
    amount { 1 }
    payment_period { 1 }
  end
end
