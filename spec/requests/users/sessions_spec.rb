require 'rails_helper'

RSpec.describe "Users::Sessions", type: :request do
  describe "GET /users/sign_in" do
    it "ログインページを表示し200を返す" do
      get new_user_session_path
      expect(response).to have_http_status(:ok)  # 200
    end
  end

  describe "POST /users/sign_in" do
    let(:user) { create(:user) }

    context "有効な入力値の場合" do
      it "ログインに成功し303を返す" do
        post user_session_path, params: { user: { email: user.email, password: user.password } }
        expect(response).to have_http_status(:see_other)  # 303
      end
    end

    context "不正な入力値の場合" do
      it "ログインに失敗し422を返す" do
        post user_session_path, params: { user: { email: user.email, password: "wrongpassword" } }
        expect(response).to have_http_status(:unprocessable_entity)  # 422
      end
    end
  end

  describe "DELETE /users/sign_out" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "ログアウトに成功し302を返す" do
      delete destroy_user_session_path
      expect(response).to have_http_status(:see_other)  # 303
    end
  end
end
