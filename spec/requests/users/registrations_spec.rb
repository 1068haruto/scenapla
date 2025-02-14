require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:user) { create(:user) }

  describe "POST /users" do
    it "有効なサインアップ後に303を返す" do
      post user_registration_path, params: { user: attributes_for(:user).except(:confirmed_at) }
      expect(response).to have_http_status(:see_other)  # 303
    end
  end

  describe "PUT /users" do
    before { sign_in user }

    it "ユーザー情報更新時に302を返す" do
      put user_registration_path, params: { user: { name: "新しいユーザー名" } }
      expect(response).to have_http_status(:redirect)  # 302
    end

    it "ユーザー情報更新失敗時に422を返す" do
      put user_registration_path, params: { user: { name: nil } }
      expect(response).to have_http_status(:unprocessable_entity)  # 422
    end
  end

  describe "GET /users/date_of_birth/edit" do
    context "ログイン済の場合" do
      before { sign_in user }

      it "ページを表示し200を返す" do
        get edit_date_of_birth_path
        expect(response).to have_http_status(:success)  # 200
      end
    end

    context "未ログインの場合" do
      before { sign_out user }

      it "ログインページにリダイレクトし302を返す" do
        get edit_date_of_birth_path
        expect(response).to have_http_status(:redirect)  # 302
      end
    end
  end

  describe "PATCH /users/date_of_birth" do
    context "ログイン済の場合" do
      before { sign_in user }

      it "更新に成功し302を返す" do
        patch update_date_of_birth_path, params: { user: { date_of_birth: "2000-01-01" } }
        expect(response).to have_http_status(:redirect)
      end

      it "不正な値入力では更新失敗し、422を返す" do
        patch update_date_of_birth_path, params: { user: { date_of_birth: nil } }
        expect(response).to have_http_status(:unprocessable_entity)  # 422
      end
    end

    context "未ログインの場合", :focus do
      before { sign_out user }

      it "ログインページにリダイレクトし、302を返す" do
        patch update_date_of_birth_path, params: { user: { date_of_birth: "2000-01-01" } }
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
