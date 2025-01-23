module ApplicationHelper
  # OGPに使用するFACEBOOKのアプリID
  def facebook_app_id
    ENV['FACEBOOK_APP_ID'] || Rails.application.credentials.dig(:facebook, :app_id)
  end
end
