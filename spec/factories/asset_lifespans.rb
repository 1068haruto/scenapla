FactoryBot.define do
  factory :asset_lifespan do
    user
    simulation
    asset_lifespan_scenario { [
      { "date" => Date.current.year, "amount" => "1.0" },
      { "date" => Date.current.year + 1, "amount" => "2.0" }
    ] }
    lifespan_years { 1 }
    lifespan_months { 0 }
  end
end
