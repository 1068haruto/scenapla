class LifeEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_life_events, only: [ :index, :create, :edit, :update, :destroy ]
  before_action :set_life_event_or_redirect, only: [ :edit, :update, :destroy ]

  def index
    @life_event = LifeEvent.new
  end

  def create
    @life_event = current_user.life_events.build(life_event_params)
    @life_event.simulation = current_user.simulation

    if @life_event.save
      redirect_to life_events_path, notice: t("common.actions.create", model: "ライフイベントデータ")
    else
      render_error(@life_event.errors.full_messages.join, :unprocessable_entity)
    end
  end

  def edit
    render :index
  end

  def update
    if @life_event.update(life_event_params)
      redirect_to life_events_path, notice: t("common.actions.update", model: "ライフイベントデータ")
    else
      render_error(@life_event.errors.full_messages.join, :unprocessable_entity)
    end
  end

  def destroy
    if @life_event.destroy
      redirect_to life_events_path, notice: t("common.actions.destroy", model: "ライフイベントデータ")
    else
      render_error(t("common.actions.destroy_failed", model: "ライフイベントデータ"), :unprocessable_entity)
    end
  end

  private

  def set_life_events
    @life_events = current_user.life_events.order(event_date: :asc)
  end

  def set_life_event_or_redirect
    @life_event = current_user.life_events.find_by(id: params[:id])  # 存在しない場合、nilとする

    unless @life_event
      redirect_to life_events_path, alert: t("common.actions.not_found", model: "ライフイベントデータ")
    end
  end

  def life_event_params
    params.require(:life_event).permit(:event_type, :event_date, :title, :amount, :payment_period)
      .tap { |p| p[:event_type] = p[:event_type].to_i if p[:event_type].present? }
  end

  def render_error(message, status)
    flash.now[:alert] = message
    render :index, status: status
  end
end
