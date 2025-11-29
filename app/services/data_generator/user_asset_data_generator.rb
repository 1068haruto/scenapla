module DataGenerator
  class UserAssetDataGenerator
    # コンストラクタでuserを受け取り
    def initialize(user)
      @user = user
    end

    # user_asset_dataの生成-> Array
    def call
      assets = @user.user_assets
      current_year = Date.today.year
      year_at_seventy = @user.get_year_at_seventy
      yearly_totals = Hash.new(0)

      assets.each do |asset|
        # 1年目
        amount = asset.amount
        rate = asset.return_rate.to_f / 100.0  # 小数変換(例: 10% の場合は、0.1)
        yearly_totals[current_year] += amount  # 利回り計算なし

        # 2年目以降
        (current_year + 1..year_at_seventy).each do |year|
          profit = amount * rate
          if asset.asset_type == Constants::ASSET_TYPE_IS_OTHER
            profit -= profit * Constants::TAX_RATE
          end
          amount += profit
          yearly_totals[year] += amount
        end
      end

      FormatService.format(yearly_totals)
    end
  end
end
