FactoryBot.define do
  factory :income do
    user
    simulation
    person_type { "本人" }
    income { 1 }
    retirement_date { Date.new(2030, 1, 1) }
    retirement_pay { 1 }
  end
end
