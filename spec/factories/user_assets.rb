FactoryBot.define do
  factory :user_asset do
    user
    simulation
    person_type { 0 }
    asset_type { 2 }
    amount { 10 }
    return_rate { 10 }
  end
end
