FactoryBot.define do
  factory :life_event do
    user
    simulation

    # 現実イベント
    event_type { 0 }
    event_date { Date.current.year }
    title { "現実イベント" }
    amount { 1 }
    payment_period { 1 }

    # trait
    # 理想用イベント
    trait :ideal do
      event_type { 1 }
      event_date { Date.current.year + 3}
      title { "理想イベント" }
      amount { 3 }
      payment_period { 3 }
    end
  end
end
