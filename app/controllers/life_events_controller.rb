class LifeEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_life_events, only: [ :index, :create, :edit, :update, :destroy ]
  before_action :set_life_event, only: [ :edit, :update, :destroy ]

  def index
    @life_event = LifeEvent.new
  end

  def create
    @life_event = current_user.life_events.build(life_event_params)
    @life_event.simulation = current_user.simulation

    if @life_event.save
      redirect_to life_events_path, notice: t("message.life_event.create.success")
    else
      render_error(@life_event.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def edit
    if @life_event
      render :index
    else
      render_error(t("message.life_event.edit.failure"), :not_found)
    end
  end

  def update
    if @life_event.update(life_event_params)
      redirect_to life_events_path, notice: t("message.life_event.update.success")
    else
      render_error(@life_event.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def destroy
    if @life_event.destroy
      redirect_to life_events_path, notice: t("message.life_event.destroy.success")
    else
      render_error(t("message.life_event.destroy.failure"), :not_found)
    end
  end

  private

  def set_life_events
    @life_events = current_user.life_events.order(event_date: :asc)
  end

  def set_life_event
    @life_event = current_user.life_events.find(params[:id])
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
