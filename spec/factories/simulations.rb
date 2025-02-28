FactoryBot.define do
  factory :simulation do
    user
    income_data { nil }
    expense_data { nil }
    user_asset_data { nil }
    real_event_data { nil }
    ideal_event_data { nil }
  end
end
