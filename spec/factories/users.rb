FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    email { "test@example.com" }
    date_of_birth { "1990-01-01" }
    password { "password1234" }
    password_confirmation { password }
  end
end
