class LifeEventsController < ApplicationController
  def index
    # ユーザーのライフイベントを取得して年代ごとにグループ化
    life_events = LifeEvent.where(user_id: current_user.id).order(event_date: :asc)
    @grouped_life_events = life_events.group_by { |event| calculate_age_group(event.event_date.year, current_user.date_of_birth.year) }
  end
  
  def new
    @life_event = LifeEvent.new
    @life_events = LifeEvent.where(user_id: current_user.id).order(event_date: :asc)
  end

  def create
    @life_event = LifeEvent.build(convert_event_date(life_event_params))
    if @life_event.save
      respond_to_format
    else
      @life_events = LifeEvent.where(user_id: current_user.id).order(event_date: :asc)
      render :new
    end
  end

  def destroy
    @life_event = LifeEvent.find(params[:id])

    if @life_event.destroy
      respond_to_format_destroy
    else
      redirect_to new_life_event_path, alert: 'ライフイベントの削除に失敗しました。'
    end
  end

  def update_life_event_data
    simulation_id = params[:simulation_id]
  
    if LifeEvent.update_simulation_data(simulation_id)
      redirect_to new_life_event_path, notice: 'LifeEventDataが更新されました。'
    else
      redirect_to new_life_event_path, alert: 'LifeEventDataの更新に失敗しました。'
    end
  end

  private

  def life_event_params
    params.require(:life_event).permit(:user_id, :simulation_id, :age_group, :event_type, :event_date, :title, :amount, :payment_span).tap do |whitelisted|
      whitelisted[:event_type] = whitelisted[:event_type].to_i
      whitelisted[:payment_span] = whitelisted[:payment_span].to_i
    end
  end

  def convert_event_date(params)
    if params[:event_date].present?
      params[:event_date] = Date.new(params[:event_date].to_i, 1, 1)
    end
    params
  end

  def respond_to_format
    respond_to do |format|
      format.html { redirect_to life_events_path, notice: 'ライフイベントが保存されました！' }
      format.turbo_stream
    end
  end

  def respond_to_format_destroy
    respond_to do |format|
      format.html { redirect_to life_events_path, notice: 'ライフイベントが削除されました！' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@life_event) }
      #format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@user_asset)) }
    end
  end

  # 年代を計算するメソッド
  def calculate_age_group(event_year, birth_year)
    age = event_year - birth_year
    (age / 10) * 10 # 30代, 40代などに変換
  end
end
