require 'rails_helper'

RSpec.describe "UserAssets", type: :request do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:user_asset) { create(:user_asset, user: user, simulation: simulation) }

  # パラメータ
  let(:valid_params) { attributes_for(:user_asset) }
  let(:valid_params_for_update) { { amount: 20 } }
  let(:invalid_params) { { amount: -20 } }

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
    context "有効なパラメータの場合" do
      it "作成成功し、302を返す" do
        post user_assets_path, params: { user_asset: valid_params }
        expect(response).to have_http_status(:found) # 302
      end
    end

    context "無効なパラメータの場合" do
      it "作成失敗し、422を返す" do
        post user_assets_path, params: { user_asset: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "GET /edit" do
    context "編集したいデータが存在する場合" do
      it "編集フォームを表示し、200を返す" do
        get edit_user_asset_path(user_asset)
        expect(response).to have_http_status(:success) # 200
      end
    end

    context "編集したいデータが存在しない場合" do
      it "編集フォームを表示せず、404を返す" do
        get edit_user_asset_path(-1) # 存在しないID
        expect(response).to have_http_status(:not_found) # 404
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "更新成功し、302を返す" do
        patch user_asset_path(user_asset), params: { user_asset: valid_params_for_update }
        expect(response).to have_http_status(:found) # 302

        user_asset.reload
        expect(user_asset.amount).to eq 20
      end
    end

    context "無効なパラメータの場合" do
      it "更新失敗し、422を返す" do
        patch user_asset_path(user_asset), params: { user_asset: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "DELETE /destroy" do
    context "削除したいデータが存在する場合" do
      it "削除成功し、302を返す" do
        delete user_asset_path(user_asset)
        expect(response).to have_http_status(:found) # 302
      end
    end

    context "削除したいデータが存在しない場合" do
      it "削除失敗し、404を返す" do
        delete user_asset_path(-1) # 存在しないID
        expect(response).to have_http_status(:not_found) # 404
      end
    end
  end
end
