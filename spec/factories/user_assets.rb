FactoryBot.define do
  factory :user_asset do
    user
    simulation
    person_type { "本人" }
    asset_type { "投資_その他" }
    amount { 100 }
    return_rate { 10 }
  end
end
