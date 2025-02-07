FactoryBot.define do
  factory :memo do
    user
    age_group { 20 }
    content { "メモの内容" }
  end
end
