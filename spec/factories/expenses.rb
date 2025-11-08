FactoryBot.define do
  factory :expense do
    user
    simulation
    housing_expenses { 1 }
    living_expenses { 1 }
    monthly_premiums { 1 }
    other_expenses { 1 }
    repayment_date { Date.today.year + 3 }
  end
end

# (生活費 + 保険費 + その他費用 + 住居費) == 4
# (生活費 + 保険費 + その他費用        ) == 3
