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

  def self.calculate_user_assets(user)
    # 対象ユーザーの資産データ取得
    assets = where(user: user)

    # ユーザーが70歳になる年を計算
    current_year = Date.today.year
    user_age = current_year - user.date_of_birth.year
  
    if user_age >= 70
      errors.add(:base, "既に70歳以上のため計算を実行できません")
      return
    end
  
    seventy_year_old_year = current_year + (70 - user_age)

    # 年ごとの資産合計を保持
    yearly_totals = Hash.new(0)

    # 資産データごとに計算
    assets.each do |asset|
      initial_amount = asset.amount || 0
      rate = (asset.return_rate.to_f || 0) / 100.0 # 利回りを小数に変換
      asset_type = asset.asset_type

      # 初年度の金額を設定（利回り計算なし）
      yearly_totals[current_year] += initial_amount

      # 利回り計算に使用する元本
      amount = initial_amount

      # 2年目以降の各年の試算計算
      (current_year + 1..seventy_year_old_year).each do |year|
        if rate > 0
          profit = amount * rate # 利益計算

          # 資産タイプが4の場合、利益の20%を課税
          profit -= profit * 0.2 if asset_type == "投資_その他"

          # 利益を加算した金額を次年の元本とする
          amount += profit
        end

        # 年ごとの資産合計を更新（重複加算を防ぐ）
        yearly_totals[year] += amount
      end
    end

    # 年ごとの結果を小数第1位まで丸める
    yearly_totals.transform_values! { |v| v.round(1) }

    # 結果をハッシュ配列に整形
    yearly_totals.map { |year, total| { date: year, amount: total } }
  end
end
