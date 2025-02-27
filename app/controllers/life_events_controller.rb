class LifeEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_life_events, only: [ :index, :new, :create, :destroy ]

  def index
    @age_groups_to_display = ((current_user.calculate_user_age / 10) * 10..70).step(10).to_a
    @grouped_life_events = @life_events.group_by {
      |event| calculate_age_group(event.event_date.year, current_user.date_of_birth.year)
    }
    @memos = current_user.memos.group_by(&:age_group)

    @advice_record = current_user.ai_advices.last
    @advice = @advice_record.present? ? @advice_record.content : nil
  end

  def new
    @life_event = LifeEvent.new
  end

  def create
    @life_event = current_user.life_events.build(life_event_params)
    @life_event.simulation = current_user.simulation

    if @life_event.save
      redirect_to new_life_event_path, notice: t("message.life_event.create.success")
    else
      render_error(@life_event.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def destroy
    life_event = current_user.life_events.find(params[:id])

    if life_event.destroy
      redirect_to new_life_event_path, notice: t("message.life_event.destroy.success")
    else
      render_error(t("message.life_event.destroy.failure"), :not_found)
    end
  end

  def update_simulation_data
    if current_user.simulation.update_life_event_data!(current_user)
      redirect_to scenarios_path, notice: t("message.simulation.update.success")
    else
      redirect_to new_life_event_path, alert: t("message.simulation.update.failure")
    end
  end

  private

  def set_life_events
    @life_events = current_user.life_events.order(event_date: :asc)
  end

  def life_event_params
    params.require(:life_event).permit(:event_type, :event_date, :title, :amount, :payment_period)
      .tap { |p| p[:event_type] = p[:event_type].to_i if p[:event_type].present? }
  end

  def render_error(message, status)
    flash.now[:alert] = message
    render :new, status: status
  end

  def calculate_age_group(event_year, birth_year)
    age = event_year - birth_year
    (age / 10) * 10
  end
end
