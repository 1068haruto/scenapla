class AfterBaseController < ApplicationController
  include Constants
  before_action :authenticate_user!

  protected # 継承先でのみ使うため

  def updater
    @updater ||= DataUpdater::SimulationDataUpdater.new(current_user)
  end

  def execute_sim_update(method:, success_path:, failure_path:)
    if updater.send(method)
      redirect_to success_path,
      notice: t("common.actions.update", data: SIMULATION_DATA)
    else
      redirect_to failure_path,
      alert: t("common.actions.update_failed", data: SIMULATION_DATA)
    end
  end

  def render_error(message, status)
    flash.now[:alert] = message
    render :index, status: status
  end
end
