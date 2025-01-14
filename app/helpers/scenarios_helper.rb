module ScenariosHelper
  # 日付表示部分
  def formatted_date(date)
    date.present? ? date.strftime('%Y年%m月%d日') : ''
  end
end
