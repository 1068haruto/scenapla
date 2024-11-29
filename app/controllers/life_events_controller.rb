class LifeEventsController < ApplicationController
  def index
    @life_event = LifeEvent.new
  end

  def create
    @life_event = LifeEvent.build(convert_event_date(life_event_params))
    if @life_event.save
      redirect_to life_events_path, notice: 'ライフイベントが保存されました！'
    else
      render :index
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
end
