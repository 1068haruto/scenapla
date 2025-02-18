class OpenaiAdvicesController < ApplicationController
  before_action :authenticate_user!

  def generate_advice
    @advice = OpenaiAdviceService.new(current_user).generate_and_save_advice
    redirect_to life_events_path, notice: "アドバイスを更新しました。"
  end
end
