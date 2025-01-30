FactoryBot.define do
  factory :life_event do
    user
    simulation
    event_type { "理想" }
    event_date { Date.today }
    title { "旅行" }
    amount { 1 }
    payment_span { 1 }
  end
end
