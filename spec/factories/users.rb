FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    email { "test@example.com" }
    password { "password1234" }
    password_confirmation { password }
    confirmed_at { Time.current }
    date_of_birth { Date.new(Date.today.year - 40, 1, 1) }
  end
end
