class FormatService

  # 同じ年が持つ複数のamountを丸め、合計する-> オブジェクト配列
  def self.format(yearlyTotals)

    roundedHash = yearlyTotals.transform_values do |totalAmount|
      totalAmount.round(1)  # 小数第1位
    end

    yearlyArray = []
    roundedHash.each do |year, totalAmount|
      yearlyArray << { date: year, amount: totalAmount }
    end

    yearlyArray
  end
end