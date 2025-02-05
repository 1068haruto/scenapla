FactoryBot.define do
  factory :user do
    transient do
      date_of_birth { nil } # デフォルトはnil
    end

    name { "テストユーザー" }
    email { "test@example.com" }
    password { "password1234" }
    password_confirmation { password }
    confirmed_at { Time.current }

    initialize_with do
      dob = Date.today.year - 40

      if attributes[:skip_create]
        new(attributes.except(:skip_create).merge(date_of_birth: dob))  # buildの場合
      else
        new(attributes.except(:skip_create).merge(date_of_birth: Date.new(dob, 1, 1)))  # createの場合
      end
    end
  end
end
