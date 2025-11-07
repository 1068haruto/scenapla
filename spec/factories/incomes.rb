FactoryBot.define do
  factory :income do
    user
    simulation
    person_type { "本人" }
    monthly_income { 1 }
    yearly_bonus { 1 }
    retirement_date { Date.current.year + 5 }
    retirement_pay { 1 }
  end
end
