FactoryBot.define do
  factory :income do
    user
    simulation
    person_type { "本人" }
    monthly_income { 1 }
    yearly_bonus { 0 }
    retirement_date { 2030 }
    retirement_pay { 1 }
  end
end
