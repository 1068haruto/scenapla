class UserAsset < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  AGE_LIMIT = 70
  TAX_RATE = 0.2
  ASSET_TYPE_IS_OTHER = "投資_その他"

  enum person_type: { 本人: 0, 配偶者: 1 }
  enum asset_type: { 預金: 0, 貯蓄型保険: 1, 投資_NISA: 2, 投資_iDeCo: 3, 投資_その他: 4 }

  validates :user_id, :simulation_id, presence: true
  validates :person_type, :asset_type, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :return_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.generate_user_asset_data_for(user)
    assets = where(user: user)
    year_at_seventy = get_year_when_seventy(user)

    yearly_totals = initialize_yearly_totals(assets, year_at_seventy)
    format_yearly_totals(yearly_totals)
  end

  private

  # ユーザーが70歳になる年を計算
  def self.get_year_when_seventy(user)
    current_year = Date.today.year
    user_age = current_year - user.date_of_birth.year
    current_year + (AGE_LIMIT - user_age)
  end

  def self.initialize_yearly_totals(assets, year_at_seventy)
    current_year = Date.today.year
    yearly_totals = Hash.new(0)

    assets.each do |asset|
      calculate_asset_projection(asset, yearly_totals, current_year, year_at_seventy)
    end
    yearly_totals
  end

  def self.calculate_asset_projection(asset, yearly_totals, current_year, year_at_seventy)
    initial_amount = asset.amount || 0
    rate = (asset.return_rate.to_f || 0) / 100.0  # 利回りを小数変換

    # 1年目の資産計算(利回り計算なし)
    yearly_totals[current_year] += initial_amount
    # 2年目以降の各年の資産計算
    calculate_future_years(asset.asset_type, initial_amount, rate, yearly_totals, current_year, year_at_seventy)
  end

  def self.calculate_future_years(asset_type, initial_amount, rate, yearly_totals, current_year, year_at_seventy)
    amount = initial_amount  # 初期元本(1年目の資産合計)

    (current_year + 1..year_at_seventy).each do |year|
      if rate > 0
        profit = calculate_profit(amount, rate, asset_type)
        amount += profit  # 元本に利益加算
      end
      yearly_totals[year] += amount  # 年毎に資産を更新(重複加算を防ぐ)
    end
  end

  # 利益計算
  def self.calculate_profit(amount, rate, asset_type)
    profit = amount * rate
    profit -= profit * TAX_RATE if asset_type == ASSET_TYPE_IS_OTHER  # 資産種類が4の場合、利益の20%を課税
    profit
  end

  # 各年の金額を小数第1位までにし、ハッシュ配列に整形
  def self.format_yearly_totals(yearly_totals)
    yearly_totals.transform_values! { |v| v.round(1) }
    yearly_totals.map { |year, total| { date: year, amount: total } }
  end
end
