FactoryBot.define do
  factory :scenario do
    user
    simulation
    scenario_type { "現実" }
    total_income { nil }
    total_expense { nil }
    total_balance { nil }
    asset_scenario { nil }
    balance_scenario { [ { "date" => 2000, "amount" => 100 } ] }
    withdrawal { nil }
    shortage { nil }
    updated_at { 1.day.ago }
  end
end
