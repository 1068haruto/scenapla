class ScenariosController < ApplicationController
  def index
    @simulation = Simulation.find_by(user_id: current_user.id)
    @scenario = Scenario.find_by(user_id: current_user.id)
    @chart_data = @scenario.chart_data
  end
end
