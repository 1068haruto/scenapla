class UserAsset < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  AGE_LIMIT = 70
  TAX_RATE = 0.20315  # 20.315％（所得税等15.315％、住民税５％）
  ASSET_TYPE_IS_OTHER = "投資_その他"

  enum person_type: { 本人: 0, 配偶者: 1 }
  enum asset_type: { 預金: 0, 貯蓄型保険: 1, 投資_NISA: 2, 投資_iDeCo: 3, 投資_その他: 4 }

  validates :user_id, :simulation_id, presence: true
  validates :person_type, :asset_type, presence: true
  validates :amount, :return_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.generate_user_asset_data_for(user)
    assets = where(user: user)
    year_at_seventy = get_year_when_seventy(user)
    yearly_totals = initialize_yearly_totals(assets, year_at_seventy)

    format_yearly_totals(yearly_totals)
  end

  private

  # ユーザーが70歳になる年を計算
  def self.get_year_when_seventy(user)
    birth_date = user.date_of_birth
    year_turns_seventy = birth_date + AGE_LIMIT.years
    year_turns_seventy.year
  end

  def self.initialize_yearly_totals(assets, year_at_seventy)
    current_year = Date.today.year
    yearly_totals = Hash.new(0)

    assets.each do |asset|
      calculate_asset_projection(asset, yearly_totals, current_year, year_at_seventy)
    end
    yearly_totals
  end

  # 1年目の資産設定 & 2年目以降の計算メソッド呼び出し
  def self.calculate_asset_projection(asset, yearly_totals, current_year, year_at_seventy)
    amount = asset.amount
    rate = asset.return_rate.to_f / 100.0  # 利回りの小数変換（例　10%の場合：0.1）

    yearly_totals[current_year] += amount  # 1年目の資産(利回り計算なし)

    calculate_future_years(asset.asset_type, amount, rate, yearly_totals, current_year, year_at_seventy)
  end

  # 2年目以降の資産計算
  def self.calculate_future_years(asset_type, amount, rate, yearly_totals, current_year, year_at_seventy)
    (current_year + 1..year_at_seventy).each do |year|
      profit = calculate_profit(amount, rate, asset_type)
      amount += profit
      yearly_totals[year] += amount
    end
  end

  # 利益計算
  def self.calculate_profit(amount, rate, asset_type)
    profit = amount * rate
    profit -= profit * TAX_RATE if asset_type == ASSET_TYPE_IS_OTHER  # 資産種類が4の場合、利益の20.315%を課税
    profit
  end

  # 各年の金額を小数第1位までにし、ハッシュ配列に整形
  def self.format_yearly_totals(yearly_totals)
    yearly_totals.transform_values! { |v| v.round(1) }
    yearly_totals.map { |year, total| { date: year, amount: total } }
  end
end
