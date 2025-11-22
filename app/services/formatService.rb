require "bigdecimal"

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

  # 各エントリから "amount" の値を取り出し、BigDecimal に変換して合計-> BigDecimal
  def self.sum_entries(entries)
    entries.sum(BigDecimal("0.0")) { |entry| entry["amount"].to_d }
  end

  # チャート用のハッシュ形式に変換（1つでも不正があればエラーとする）--> Array
  # [{"date": "2025", "amount": 100}, ...] → {"2025" => 100, ...}
  def self.to_chart_hash(data_array)
    return {} if data_array.blank?

    data_array.map do |entry|
      unless entry.is_a?(Hash) && entry.key?("date") && entry.key?("amount")
        # entry は Hash であり、必要なキーを必ず持つ
        raise ArgumentError, "不正なデータ形式が見つかりました: #{entry.inspect}"
      end

      [ entry["date"], entry["amount"].to_d ]
    end.to_h
  end
  # .to_h は、キーと値のペアの配列をハッシュに変換する
  # [[key1, value1], [key2, value2], .. ] → { key1 => value1, key2 => value2, .. }
end
