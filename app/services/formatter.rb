require "bigdecimal"

class Formatter
  # simulation_data用フォーマット -> Array
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

  # 生涯合計額取得 -> BigDecimal
  def self.sum_entries(entries)
    entries.sum(BigDecimal("0.0")) { |entry| entry["amount"].to_d }
  end

  # チャート用フォーマット -> Array
  def self.to_chart_hash(data_array)
    return {} if data_array.blank?

    data_array.map do |entry|
      unless entry.is_a?(Hash) && entry.key?("date") && entry.key?("amount")
        # 不正entryあればエラー
        raise ArgumentError, "不正なデータ形式が見つかりました: #{entry.inspect}"
      end

      [ entry["date"], entry["amount"].to_d ]
    end.to_h
  end
  # 変換の例：[{"date": "2025", "amount": 100}, ..] → {"2025" => 100, .. }
  # .to_h の例：[[key1, value1], .. ] → { key1 => value1, .. }
end
