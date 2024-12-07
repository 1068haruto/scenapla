class ScenariosController < ApplicationController
  def index
    @simulation = Simulation.find_by(user_id: current_user.id)
    @scenario = Scenario.find_by(user_id: current_user.id)
    #現実的シナリオ
    @chart_data = @scenario.balance_chart_data
    #@total_income = @scenario.total_income
    #@total_expense = @scenario.total_expense
    #@total_balance = @total_expense + @total_income

    @real_total_income = @scenario.total_income || 0
    @real_total_expense = @scenario.total_expense || 0
    @real_total_balance = @scenario.total_balance || 0
    @real_withdrawal = @scenario.withdrawal || 0
    @real_shortage = @scenario.shortage || 0
  end
end
