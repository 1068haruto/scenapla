FactoryBot.define do
  factory :asset_lifespan do
    user
    simulation
    asset_lifespan_scenario { { "2000" => 10, "2001" => -10 } }
    lifespan_years { 1 }
    lifespan_months { 0 }
  end
end
