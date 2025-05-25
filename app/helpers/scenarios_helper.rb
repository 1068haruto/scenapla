module ScenariosHelper
  # 条件分岐 -----------------------------
  def show_asset_lifespan_scenario?
    @asset_lifespan.present? && @asset_lifespan.asset_lifespan_scenario.present?
  end

  def show_balance_scenario?(balance_chart_data)
    !balance_chart_data.empty? && @incomes.any? && @expenses.any?
  end

  def show_asset_scenario?
    !@asset_data.empty? && @user_assets.any?
  end

  def show_next_button?(simulation)
    simulation.user_asset_data.present? && simulation.user_asset_data.any?
  end

  # 日付表示部分 --------------------------
  def formatted_date(date)
    date.present? ? date.strftime("%Y年%m月%d日") : ""
  end

  # チャート ------------------------------
  def lifespan_chart(data)
    column_chart(
      data,
      xtitle: "年",
      ytitle: "資産額",
      thousands: ",",
      suffix: "万円",
      download: { filename: "資産寿命シナリオ" }
    )
  end

  def balance_chart(data, title)
    area_chart(
      data,
      dataset: { borderWidth: 1 },
      xtitle: "年",
      ytitle: "収支額",
      thousands: ",",
      suffix: "万円",
      download: { filename: title }
    )
  end

  def asset_chart(data)
    area_chart(
      data,
      dataset: { borderWidth: 1 },
      colors: [ "#FF5733" ],
      xtitle: "年",
      ytitle: "運用資産額",
      thousands: ",",
      suffix: "万円",
      download: { filename: "運用資産シナリオ" }
    )
  end
end
