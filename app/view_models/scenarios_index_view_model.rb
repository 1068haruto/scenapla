class ScenariosIndexViewModel
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  # データオブジェクトをインスタンス変数として保持
  attr_reader :simulation, :scenarios, :asset_lifespan, :incomes, :expenses, :user_assets
  # 各シナリオのview modelを公開
  attr_reader :asset_lifespan_vm, :real_scenario_vm, :ideal_scenario_vm, :asset_scenario_vm

  def initialize(user)
    @user = user
    @simulation = user.simulation
    @scenarios = user.scenarios
    @asset_lifespan = user.asset_lifespans.last
    @incomes = user.incomes
    @expenses = user.expenses
    @user_assets = user.user_assets

    # 各シナリオの view model を初期化し、必要なデータを渡す
    @asset_lifespan_vm = AssetLifespanViewModel.new(@asset_lifespan, @simulation)
    @real_scenario_vm  = BalanceScenarioViewModel.new(
      scenario: @scenarios.find_by(scenario_type: "現実"),
      incomes: @incomes,
      expenses: @expenses
    )
    @ideal_scenario_vm = BalanceScenarioViewModel.new(
      scenario: @scenarios.find_by(scenario_type: "理想"),
      incomes: @incomes,
      expenses: @expenses
    )
    @asset_scenario_vm = AssetScenarioViewModel.new(@simulation, @user_assets)
  end

  # 「次へ」表示判定
  def show_next_button?
    # 「資産入力 と 資産データあり」or「収入&支出入力 と 収入&支出データあり」なら表示
    @simulation.user_assets.present? && @simulation.user_asset_data.any? ||
    @simulation.incomes.present? && @simulation.expenses.present? &&
    @simulation.income_data.any? && @simulation.expense_data.any?
  end

  private

  # form_withなどのために必要（ダミー）
  def persisted?; false; end
end
