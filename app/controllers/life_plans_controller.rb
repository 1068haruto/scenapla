class LifePlansController < AfterBaseController
  before_action :set_life_plan_data, only: [ :index ]

  def index; end

  def generate_advice
    Api::OpenaiService.new(current_user).call
    redirect_to life_plans_path, notice: "アドバイスを生成しました。"
  rescue => e
    redirect_to life_plans_path, alert: e.message
  end

  def save_memo
    @memo = current_user.memos.find_or_initialize_by(age_group: memo_params[:age_group])

    @memo.content = memo_params[:content]
    if @memo.save
      redirect_to life_plans_path,
      notice: "メモを保存しました。"
    else
      redirect_to life_plans_path,
      alert: "メモの保存に失敗しました: #{@memo.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_life_plan_data
    @life_events = current_user.life_events.order(event_date: :asc)
    @age_groups = calculate_age_groups
    @grouped_life_events = group_life_events
    @memos = group_memos
    @advice = get_advice
    @remaining_advice_count = get_advice_count
    @edit_age_group = params[:edit_age_group].present? ? params[:edit_age_group].to_i : nil
  end

  def calculate_age_groups
    ((current_user.calculate_user_age / 10) * 10..70).step(10).to_a
  end

  def group_life_events
    @life_events.group_by do |event|
      age = event.event_date.year - current_user.date_of_birth.year
      (age / 10) * 10
    end
  end

  def group_memos
    current_user.memos.group_by(&:age_group)
  end

  def get_advice
    advice_record = current_user.ai_advices.last
    advice_record.present? ? advice_record.content : nil
  end

  def get_advice_count
    start_of_month = Time.zone.now.beginning_of_month
    monthly_advice_total = current_user.ai_advices.where("created_at >= ?", start_of_month).count
    result = monthly_advice_total - 3
    result < 0 ? result.abs : result
  end

  def memo_params
    params.require(:memo).permit(:age_group, :content)
  end
end
