class DashboardController < ApplicationController
  before_action :authenticate_user! # サインインしているか確認
end
