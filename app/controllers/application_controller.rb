class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :check_date_of_birth

  protected

  def after_sign_in_path_for(resource)
    if resource.date_of_birth.blank?
      edit_date_of_birth_path
    else
      dashboard_index_path
    end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)  # ログイン後とユーザー登録後のリダイレクト共通化
  end

  # 生年月日未登録者の遷移と処理制御（allowed_paths内にあるものが可能）
  def check_date_of_birth
    if user_signed_in? && current_user.date_of_birth.blank? && !allowed_paths.include?(request.path)
      redirect_to edit_date_of_birth_path, alert: "生年月日を登録してください。"
    elsif !user_signed_in? && request.path == edit_date_of_birth_path
      redirect_to new_user_session_path, alert: "ログインしてください。"
    end
  end

  private

  def allowed_paths
    [
      dashboard_index_path,        # ダッシュボードページ
      user_path(current_user),     # アカウント情報ページ
      edit_user_registration_path, # アカウント情報変更ページ
      user_registration_path,      # アカウント情報更新処理
      destroy_user_session_path,   # ログアウト処理
      edit_date_of_birth_path,     # 生年月日編集ページ
      update_date_of_birth_path,   # 生年月日更新処理
      static_pages_privacy_path,   # プライバシーポリシー
      static_pages_terms_path      # 利用規約
    ]
  end
end
