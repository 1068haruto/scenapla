require 'rails_helper'

RSpec.describe "UserAssets", type: :request do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:user_asset) { create(:user_asset, user: user, simulation: simulation) }

  let(:valid_params) { attributes_for(:user_asset) }
  let(:invalid_params) { { amount: nil } }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示し200を返す" do
      get user_assets_path
      expect(response).to have_http_status(:success) # 200
    end
  end

  describe "POST /create" do
    context "正しいフォーム入力で保存成功した場合" do
      it "user_assets_pathへリダイレクトし302を返す" do
        post user_assets_path, params: { user_asset: valid_params }
        expect(response).to have_http_status(:found) # 302
      end
    end

    context "不正フォーム入力で保存失敗した場合" do
      it "422を返す" do
        post user_assets_path, params: { user_asset: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "DELETE /destroy" do
    context "既存データがあり、削除が成功した場合" do
      it "user_assets_pathへリダイレクトし302を返す" do
        delete user_asset_path(user_asset)
        expect(response).to have_http_status(:found) # 302
      end
    end

    context "既存データがなく、削除ができない場合" do
      it "404を返す" do
        delete user_asset_path(-1) # 存在しないIDを指定
        expect(response).to have_http_status(:not_found) # 404
      end
    end
  end
end
