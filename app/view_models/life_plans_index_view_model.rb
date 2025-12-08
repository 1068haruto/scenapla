# app/view_models/life_plans_index_view_model.rb
class LifePlansIndexViewModel
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :user, :edit_age_group

  def initialize(user, params)
    @user = user
    @life_events = user.life_events.order(event_date: :asc)
    @memos = user.memos
    @ai_advices = user.ai_advices
    @edit_age_group = params[:edit_age_group].present? ? params[:edit_age_group].to_i : nil

    # グループ化されたデータを初期化時に計算
    @grouped_life_events = group_life_events
    @grouped_memos = group_memos
  end

  # 年齢グループ配列
  def age_groups
    @age_groups ||= ((@user.calculate_user_age / 10) * 10..70).step(10).to_a
  end

  # 特定の年代にライフイベントがあるか
  def has_life_events?(age_group)
    @grouped_life_events[age_group].present?
  end

  # 特定の年代のライフイベント配列
  def life_events_for_age_group(age_group)
    @grouped_life_events[age_group] || []
  end

  # 特定の年代のメモインスタンスを取得
  def memo_instance_for_age_group(age_group)
    existing_memo = @grouped_memos[age_group]&.first
    existing_memo || @user.memos.new(age_group: age_group)
  end

  # アドバイス取得
  def advice_content
    advice_record = @ai_advices.last
    advice_record.present? ? advice_record.content : nil
  end

  # アドバイス可能回数取得
  def remaining_advice_count
    start_of_month = Time.zone.now.beginning_of_month
    monthly_advice_total = @ai_advices.where("created_at >= ?", start_of_month).count
    remaining = 3 - monthly_advice_total
    remaining > 0 ? remaining : 0
  end

  # 「情報入力画面へ」or「ライフイベント編集」の表示判定
  def show_next_button?
    @grouped_life_events.empty?
  end

  # form_withなどのために必要（ダミー）
  def persisted?; false; end

  private

  # ライフイベントを年代別にグループ化
  def group_life_events
    @life_events.group_by do |event|
      age = event.event_date.year - @user.date_of_birth.year
      (age / 10) * 10
    end
  end

  # メモを年代別にグループ化
  def group_memos
    @memos.group_by(&:age_group)
  end
end
