require 'rails_helper'

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  describe "GET /users/auth/google_oauth2/callback" do
    before do
      OmniAuth.config.test_mode = true
    end

    context "認証が成功した場合" do
      let!(:user) { create(:user) }
      before do
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          uid: '123456789',
          info: { email: 'test@example.com' }
        )
      end

      it "認証後、適切にリダイレクトする" do
        get user_google_oauth2_omniauth_callback_path
        expect(response).to have_http_status(:found)  # 302
      end
    end

    context "認証が失敗した場合" do
      before do
        OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      end

      it "新規登録ページにリダイレクトする" do
        get user_google_oauth2_omniauth_callback_path
        expect(response).to redirect_to(new_user_registration_path)
      end
    end
  end
end
