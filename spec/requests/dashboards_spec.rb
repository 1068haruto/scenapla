require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let!(:user) { create(:user) }

  describe "GET /dashboard/index" do
    context "ログイン済の場合" do
      before do
        sign_in user
        get dashboard_index_path
      end

      it "ページを表示し200を返す" do
        expect(response).to have_http_status(:success)  # 200
      end
    end

    context "未ログインの場合" do
      it "loginページにリダイレクトし302を返す" do
        get dashboard_index_path
        expect(response).to have_http_status(:found) # 302リダイレクト
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
