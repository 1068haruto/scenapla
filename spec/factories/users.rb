FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    email { "test@example.com" }
    password { "password1234" }
    password_confirmation { password }
    confirmed_at { Time.current }
    date_of_birth { Date.new(Date.today.year - 40, 1, 1) }

    # user作成時のscenarioデータ作成を抑制する必要があるテストで使用。
    # 次のように使用する。let!(:user) { create(:user, :without_scenarios) }
    trait :without_scenarios do
      after(:create) { |user| user.scenarios.delete_all }
    end
  end
end
