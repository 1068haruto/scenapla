FactoryBot.define do
  factory :scenario do
    user
    simulation

    # dfault（現実シナリオ）
    trait :real do
      scenario_type { "現実" }
      total_income { 0.0 }
      total_expense { 0.0 }
      total_balance { 0.0 }
      asset_scenario { {} }
      balance_scenario { [ { "date" => Date.current.year, "amount" => 0.0 } ] }
      withdrawal { 0.0 }
      shortage { 0.0 }
      updated_at { 1.day.ago }
    end

    # Trait（理想シナリオ）
    trait :ideal do
      scenario_type { "理想" }
      total_income { 0.0 }
      total_expense { 0.0 }
      total_balance { 0.0 }
      asset_scenario { {} }
      balance_scenario { [ { "date" => Date.current.year, "amount" => 0.0 } ] }
      withdrawal { 0.0 }
      shortage { 0.0 }
      updated_at { 1.day.ago }
    end
  end
end
