class OpenaiAdvicesController < ApplicationController
  before_action :authenticate_user!

  def generate_advice
    message = OpenaiAdviceService.new(current_user).generate_and_save_advice

    if message == "アドバイスを生成しました。"
      redirect_to life_plans_path, notice: message
    else
      redirect_to life_plans_path, alert: message
    end
  end
end
