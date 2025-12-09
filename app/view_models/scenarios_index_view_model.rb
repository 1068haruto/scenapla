class ScenariosIndexViewModel
  extend ActiveModel::Naming      # モデル名付与
  include ActiveModel::Conversion # Active Recordオブジェクトの振る舞い付与

  attr_reader :user, :simulation

  def initialize(user)
    @user = user
    @simulation = user.simulation
  end

  # 資産寿命
  def asset_lifespan_vm
    @asset_lifespan_vm ||= AssetLifespanViewModel.new(asset_lifespan, @simulation)
  end

  # 現実的シナリオ
  def real_scenario_vm
    @real_scenario_vm ||= BalanceScenarioViewModel.new(
      scenario: scenarios.find_by(scenario_type: "現実"),
      incomes: incomes,
      expenses: expenses
    )
  end

  # 理想的シナリオ
  def ideal_scenario_vm
    @ideal_scenario_vm ||= BalanceScenarioViewModel.new(
      scenario: scenarios.find_by(scenario_type: "理想"),
      incomes: incomes,
      expenses: expenses
    )
  end

  # 資産運用
  def asset_scenario_vm
    @asset_scenario_vm ||= AssetScenarioViewModel.new(@simulation, user_assets)
  end

  def scenarios
    @scenarios ||= @user.scenarios
  end

  def asset_lifespan
    @asset_lifespan ||= @user.asset_lifespans.last
  end

  def incomes
    @incomes ||= @user.incomes
  end

  def expenses
    @expenses ||= @user.expenses
  end

  def user_assets
    @user_assets ||= @user.user_assets
  end

  def show_next_button?
    # 「資産入力 と 資産データあり」or「収入&支出入力 と 収入&支出データあり」なら表示
    @simulation.user_assets.present? && @simulation.user_asset_data.any? ||
    @simulation.incomes.present? && @simulation.expenses.present? &&
    @simulation.income_data.any? && @simulation.expense_data.any?
  end

  # form_withなどに必要（ダミー）
  def persisted?; false; end
end
