class FormatService

  # 年毎にamountを合計済の配列 を受け取り、丸めてフォーマット-> オブジェクト配列
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