require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  # トップ ページ
  describe "GET /static_pages/index" do
    it "ページを表示する（200）" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

  # 利用規約 ページ
  describe "GET /static_pages/terms" do
    it "ページを表示する（200）" do
      get terms_path
      expect(response).to have_http_status(:success)
    end
  end

  # プライバシーポリシー ページ
  describe "GET /static_pages/privacy" do
    it "ページを表示する（200）" do
      get privacy_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /static_pages/dashboard" do
    let!(:user) { create(:user) }

    context "ログイン済の場合" do
      before do
        sign_in user
        get dashboard_path
      end

      it "ページを表示し200を返す" do
        expect(response).to have_http_status(:success)
      end
    end

    context "未ログインの場合" do
      it "loginページにリダイレクトし302を返す" do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
