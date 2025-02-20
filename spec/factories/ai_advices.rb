FactoryBot.define do
  factory :ai_advice do
    user
    content { "サンプルアドバイス" }
    real_scenario_updated_at { Time.zone.now }
  end
end
