class IncomesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incomes, only: [ :index, :edit, :update, :create, :destroy ]
  before_action :set_income, only: [ :edit, :update, :destroy ]

  def index
    @income = Income.new
  end

  def create
    @income = current_user.incomes.build(income_params)
    @income.simulation = current_user.simulation

    if @income.save
      redirect_to incomes_path, notice: t("message.income.create.success")
    else
      render_error(@income.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def edit
    if @income
      render :index
    else
      render_error(t("message.income.edit.failure"), :not_found)
    end
  end

  def update
    if @income.update(income_params)
      redirect_to incomes_path, notice: t("message.income.update.success")
    else
      render_error(t("message.income.update.failure"), :unprocessable_entity)
    end
  end

  def destroy
    if @income.destroy
      redirect_to incomes_path, notice: t("message.income.destroy.success")
    else
      render_error(t("message.income.destroy.failure"), :not_found)
    end
  end

  private

  def set_incomes
    @incomes = current_user.incomes
  end

  def set_income
    @income = current_user.incomes.find(params[:id])
  end

  def income_params
    params.require(:income).permit(:person_type, :monthly_income, :yearly_bonus, :retirement_date, :retirement_pay)
  end

  def render_error(message, status)
    flash.now[:alert] = message
    render :index, status: status
  end
end
