class UserAsset < ApplicationRecord
  include Constants

  belongs_to :user
  belongs_to :simulation

  enum person_type: { 本人: 0, 配偶者: 1 }
  enum asset_type: { 預金: 0, 貯蓄型保険: 1, 投資_NISA: 2, 投資_iDeCo: 3, 投資_その他: 4 }

  validates :user_id, :simulation_id, presence: true
  validates :person_type, :asset_type, presence: true
  validates :amount, :return_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # user_asset_dataを生成-> Array
  def self.generate_user_asset_data(user)
    assets = where(user: user)
    currentYear = Date.today.year
    yearAtSeventy = user.get_year_at_seventy
    yearlyTotals = Hash.new(0)

    assets.each do |asset|
      # 1年目
      amount = asset.amount
      rate = asset.return_rate.to_f / 100.0  # 小数変換(例: 10% の場合は、0.1)
      yearlyTotals[currentYear] += amount    # 1年目は利回り計算なし

      # 2年目以降
      (currentYear + 1..yearAtSeventy).each do |year|
        profit = amount * rate
        if asset.asset_type == ASSET_TYPE_IS_OTHER
          profit -= profit * TAX_RATE
        end
        amount += profit
        yearlyTotals[year] += amount
      end
    end

    FormatService.format(yearlyTotals)
  end
end
