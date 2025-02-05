FactoryBot.define do
  factory :user_asset do
    user
    simulation
    person_type { "本人" }
    asset_type { "預金" }
    amount { 10 }
    return_rate { 10 }
  end
end
