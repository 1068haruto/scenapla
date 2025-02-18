class OpenaiAdvicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @advice = OpenaiAdviceService.new(current_user).generate_advice
  end
end