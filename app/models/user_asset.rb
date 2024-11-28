class UserAsset < ApplicationRecord
  belongs_to :user
  belongs_to :simulation

  enum person_type: {本人: 0, 配偶者: 1}
  enum asset_type: {預金: 0, 貯蓄型保険: 1, 投資_NISA: 2, 投資_iDeCo: 3, 投資_その他: 4}

  validates :user_id, presence: true
  validates :simulation_id, presence: true
  validates :person_type, presence: true
  validates :asset_type, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :return_rate, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  # 資産データを基に計算
  def self.calculate_user_assets(user)
    # 対象ユーザーの資産データ取得
    assets = where(user: user)

    # 定年退職年の計算
    retirement_year = user.incomes.where(person_type: "本人").last.retirement_date.year
    current_year = Time.current.year

    # ハッシュ配列初期化
    result = []

    # 年ごとの合計を保持
    yearly_totals = Hash.new(0)

    # 資産データごとに計算
    assets.each do |asset|
      initial_amount = asset.amount || 0
      rate = (asset.return_rate.to_f || 0) / 100.0 # 明示的に小数へ変換
      asset_type = asset.asset_type

      # 初年度の金額を設定（この時点では利回りを適用しない）
      yearly_totals[current_year] += initial_amount

      # 各年の資産計算（翌年から退職年まで）
      amount = initial_amount
      (current_year + 1..retirement_year).each do |year|
        if rate > 0 # 利回りが0%以上なら複利計算
          amount *= (1 + rate)
        end

        # 資産タイプが4の場合、利益の20%を課税
        if asset_type == '4'
          profit = amount - (yearly_totals[year - 1] || 0)
          amount -= profit * 0.2 if profit.positive?
        end

        # 年ごとの資産合計を更新し、小数第1位まで丸める
        yearly_totals[year] += amount
        yearly_totals[year] = yearly_totals[year].round(1)
      end
    end

    # 結果をハッシュ配列に整形
    yearly_totals.each do |year, total|
      result << { date: year, amount: total.round(1) } # 結果も小数第1位に丸める
    end

    result
  end
end
