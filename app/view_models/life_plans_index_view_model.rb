class LifePlansIndexViewModel
  extend ActiveModel::Naming      # モデル名付与
  include ActiveModel::Conversion # Active Recordオブジェクトの振る舞い付与

  attr_reader :user, :edit_age_group

  def initialize(user, params)
    @user = user
    @edit_age_group = params[:edit_age_group].present? ? params[:edit_age_group].to_i : nil
  end

  def life_events
    @life_events ||= @user.life_events.order(event_date: :asc)
  end

  def memos
    @memos ||= @user.memos
  end

  def ai_advices
    @ai_advices ||= @user.ai_advices
  end

  def grouped_life_events
    @grouped_life_events ||= life_events.group_by do |event|
      age = event.event_date.year - @user.date_of_birth.year
      (age / 10) * 10
    end
  end

  def grouped_memos
    @grouped_memos ||= memos.group_by(&:age_group)
  end

  def age_groups
    @age_groups ||= ((@user.calculate_user_age / 10) * 10..70).step(10).to_a
  end

  def has_life_events?(age_group)
    grouped_life_events[age_group].present?
  end

  def life_events_for_age_group(age_group)
    grouped_life_events[age_group] || []
  end

  def memo_instance_for_age_group(age_group)
    existing_memo = grouped_memos[age_group]&.first
    existing_memo || @user.memos.new(age_group: age_group)
  end

  def advice_content
    advice_record = ai_advices.last
    advice_record.present? ? advice_record.content : nil
  end

  def remaining_advice_count
    start_of_month = Time.zone.now.beginning_of_month
    monthly_advice_total = ai_advices.where("created_at >= ?", start_of_month).count
    remaining = 3 - monthly_advice_total
    remaining > 0 ? remaining : 0
  end

  # 「情報入力画面へ」or「ライフイベント編集」表示判定
  def show_next_button?
    grouped_life_events.empty?
  end

  # form_withなどに必要（ダミー）
  def persisted?; false; end
end
