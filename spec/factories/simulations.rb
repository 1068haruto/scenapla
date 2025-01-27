FactoryBot.define do
  factory :simulation do
    user
    inflation_rate { 1.5 }
    income_data { nil }
    expense_data { nil }
    user_asset_data { nil }
    real_life_event_data { nil }
    ideal_life_event_data { nil }
  end
end