require 'bigdecimal'

class FormatService

  # 年毎にamountの値を合計済の配列 を受け取り、丸めて整形-> Array
  def self.format(yearlyTotals)
    roundedHash = yearlyTotals.transform_values do |totalAmount|
      totalAmount.round(1)  # 小数第1位
    end

    yearlyArray = []
    roundedHash.each do |year, totalAmount|
      yearlyArray << { "date" => year, "amount" => totalAmount }
    end
    yearlyArray
  end

  # 各エントリから "amount" の値を取り出し、BigDecimal 型に変換して合計-> BigDecimal
  def self.sum_entries(entries)
    entries.sum(BigDecimal('0.0')) { |entry| entry["amount"].to_d }
  end
end