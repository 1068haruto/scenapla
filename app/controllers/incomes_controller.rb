class IncomesController < AfterBaseController
  before_action :set_incomes, only: [ :index, :create, :edit, :update, :destroy ]
  before_action :set_income_or_redirect, only: [ :edit, :update, :destroy ]

  def index
    @income = Income.new
  end

  def create
    @income = current_user.incomes.build(income_params)
    @income.simulation = current_user.simulation

    if @income.save
      redirect_to incomes_path,
      notice: t("common.actions.create", data: "収入データ")
    else
      render_error(
        @income.errors.full_messages.join,
        :unprocessable_entity
      )
    end
  end

  def edit
    render :index
  end

  def update
    if @income.update(income_params)
      redirect_to incomes_path,
      notice: t("common.actions.update", data: "収入データ")
    else
      render_error(
        @income.errors.full_messages.join,
        :unprocessable_entity
      )
    end
  end

  def destroy
    if @income.destroy
      redirect_to incomes_path,
      notice: t("common.actions.destroy", data: "収入データ")
    else
      render_error(
        t("common.actions.destroy_failed", data: "収入データ"),
        :unprocessable_entity
      )
    end
  end

  private

  def set_incomes
    @incomes = current_user.incomes
  end

  def set_income_or_redirect
    @income = current_user.incomes.find_by(id: params[:id])
    unless @income
      redirect_to incomes_path,
      alert: t("common.actions.not_found", data: "収入データ")
    end
  end

  def income_params
    params.require(:income).permit(
      :person_type,
      :monthly_income,
      :yearly_bonus,
      :retirement_date,
      :retirement_pay
    )
  end
end
