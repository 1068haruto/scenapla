class LifeEventsController < ApplicationController
  def index
    # ユーザーのライフイベントを取得して年代ごとにグループ化
    life_events = LifeEvent.where(user_id: current_user.id).order(event_date: :asc)
    @grouped_life_events = life_events.group_by { |event| calculate_age_group(event.event_date.year, current_user.date_of_birth.year) }
    @memos = Memo.where(user_id: current_user.id).group_by(&:age_group)
  end

  def new
    @life_event = LifeEvent.new
    @life_events = LifeEvent.where(user_id: current_user.id).order(event_date: :asc)
  end

  def create
    @life_event = LifeEvent.build(convert_event_date(life_event_params))
    if @life_event.save
      redirect_to new_life_event_path, notice: 'ライフイベントを追加しました。'
    else
      @life_events = LifeEvent.where(user_id: current_user.id).order(event_date: :asc)
      flash.now[:error] = @life_event.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @life_event = LifeEvent.find(params[:id])

    if @life_event.destroy
      redirect_to new_life_event_path, notice: 'ライフイベントを削除しました。'
    else
      redirect_to new_life_event_path, alert: 'ライフイベントを削除できませんでした。'
    end
  end

  def update_life_event_data
    simulation_id = params[:simulation_id]

    if LifeEvent.update_simulation_data(simulation_id)
      redirect_to scenarios_path, notice: 'シミュレーションデータに保存しました。更新ボタンを押して最新のシナリオを表示しましょう。'
    else
      redirect_to new_life_event_path, alert: 'シミュレーションデータに保存できませんでした'
    end
  end

  private

  def life_event_params
    params.require(:life_event).permit(:user_id, :simulation_id, :event_type, :event_date, :title, :amount, :payment_span).tap do |whitelisted|
      whitelisted[:event_type] = whitelisted[:event_type].to_i
    end
  end

  def convert_event_date(params)
    if params[:event_date].present?
      params[:event_date] = Date.new(params[:event_date].to_i, 1, 1)
    end
    params
  end

  def calculate_age_group(event_year, birth_year)
    age = event_year - birth_year
    (age / 10) * 10 # 30代, 40代などに変換
  end
end
