class AfterBaseController < ApplicationController
  include Constants

  before_action :authenticate_user!

  def render_error(message, status)
    flash.now[:alert] = message
    render :index, status: status
  end
end
