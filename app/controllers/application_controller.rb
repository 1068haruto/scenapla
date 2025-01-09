class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  # ログイン後とサインアップ後のリダイレクト先の共通化
  def after_sign_in_path_for(resource)
    if resource.date_of_birth.blank?
      edit_date_of_birth_path
    else
      dashboard_path
    end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource) # ログイン後と同じパスを利用
  end
end
