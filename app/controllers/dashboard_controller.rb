class DashboardController < ApplicationController
  before_action :authenticate_user! # ログインしているか確認
end
