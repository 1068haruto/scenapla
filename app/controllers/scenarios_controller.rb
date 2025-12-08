class ScenariosController < AfterBaseController
  def index
    @view_model = ScenariosIndexViewModel.new(current_user)
  end

  def update_scenarios_lifespan
    if DataUpdater::DualDataUpdater.new(current_user).call
      flash[:notice] = t("common.actions.update", data: "シナリオ")
    else
      flash[:alert] = t("common.actions.update_failed", data: "シナリオ")
    end
    redirect_to scenarios_path
  end
end
