class SimulationsController < ApplicationController
  before_action :authenticate_user!

  def updater
    @updater ||= DataUpdater::SimulationDataUpdater.new(current_user)
  end

  def update_income_data
    update_data(
      method: :update_income,
      success_path: expenses_path,
      failure_path: incomes_path
    )
  end

  def update_expense_data
    update_data(
      method: :update_expense,
      success_path: user_assets_path,
      failure_path: expenses_path
    )
  end

  def update_user_asset_data
    update_data(
      method: :update_user_asset,
      success_path: life_events_path,
      failure_path: user_assets_path
    )
  end

  def update_life_event_data
    update_data(
      method: :update_life_event,
      success_path: scenarios_path,
      failure_path: life_events_path
    )
  end

  private

  def update_data(method:, success_path:, failure_path:)
    if updater.send(method)
      redirect_to success_path,
      notice: t("common.actions.save", data: "シミュレーションデータ")
    else
      redirect_to failure_path,
      alert: t("common.actions.save_failed", data: "シミュレーションデータ")
    end
  end
end
