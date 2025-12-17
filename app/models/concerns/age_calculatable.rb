module AgeCalculatable
  # インスタンスメソッドとして注入するため
  extend ActiveSupport::Concern

  # 現在の年齢を取得-> int
  def get_user_age
    return unless date_of_birth

    current_date = Date.today
    age = current_date.year - date_of_birth.year
    age -= 1 if current_date < date_of_birth + age.years
    age
  end

  # 70歳時の西暦を取得-> int
  def get_year_at_seventy
    return unless date_of_birth
    date_of_birth.year + Constants::AGE_LIMIT
  end
end
