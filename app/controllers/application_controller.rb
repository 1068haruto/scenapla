class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  # サインイン後とサインアップ後のリダイレクト先を共通化
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource) # サインイン後と同じパスを利用
  end
end
