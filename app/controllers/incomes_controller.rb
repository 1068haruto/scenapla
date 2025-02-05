class IncomesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incomes, only: [ :index, :create, :destroy ]

  def index
    @income = Income.new
  end

  def create
    @income = current_user.incomes.build(income_params)
    @income.simulation = current_user.simulation

    if @income.save
      render_success(t("notice.income.create.success"))
      head :created  # 201を返す
    else
      render_error(@income.errors.full_messages.join(", "))
    end
  end

  def destroy
    @income = current_user.incomes.find(params[:id])

    if @income
      @income.destroy
      render_success(t("notice.income.destroy.success"))
      head :no_content  # 204を返す
    else
      redirect_to incomes_path, alert: t("alert.income.destroy.not_found")
    end
  end

  def update_simulation_data
    if current_user.simulation.update_income_data!(current_user)
      redirect_to expenses_path, notice: t("notice.simulation.update.success")
    else
      redirect_to incomes_path, alert: t("alert.simulation.update.error")
    end
  end

  private

  def set_incomes
    @incomes = current_user.incomes
  end

  def income_params
    params.require(:income).permit(:person_type, :income, :retirement_date, :retirement_pay)
  end

  def render_success(message)
    flash.now[:notice] = message
    render :index, status: :unprocessable_entity
  end

  def render_error(message)
    flash.now[:error] = message
    render :index, status: :unprocessable_entity
  end
end
