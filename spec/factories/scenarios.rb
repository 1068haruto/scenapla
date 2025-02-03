FactoryBot.define do
  factory :scenario do
    user
    simulation
    scenario_type { nil }
    total_income { nil }
    total_expense { nil }
    total_balance { nil }
    asset_scenario { nil }
    balance_scenario { nil }
    withdrawal { nil }
    shortage { nil }
  end
end
