require 'rails_helper'

RSpec.describe "LifeEvents", type: :request do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:life_event) { create(:life_event, user: user, simulation: simulation) }

  # パラメータ
  let(:valid_params) { attributes_for(:life_event) }
  let(:invalid_params) { { amount: nil } }
  let(:valid_params_for_update) { { amount: 20 } }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示し、200を返す" do
      get life_events_path
      expect(response).to have_http_status(:success)  # 200
    end
  end

  describe "POST /create" do
    context "有効なパラメータの場合" do
      it "作成失敗し、302を返す" do
        post life_events_path, params: { life_event: valid_params }
        expect(response).to have_http_status(:found)  # 302
      end
    end

    context "無効なパラメータの場合" do
      it "作成失敗し、422を返す" do
        post life_events_path, params: { life_event: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)  # 422
      end
    end
  end

  describe "GET /edit" do
    context "編集したいデータが存在する場合" do
      it "編集フォームを表示し、200を返す" do
        get edit_life_event_path(life_event)
        expect(response).to have_http_status(:success) # 200
      end
    end

    context "編集したいデータがしない場合" do
      it "編集フォームを表示せず、302を返す" do
        get edit_life_event_path(-1)                     # 存在しないID
        expect(response).to have_http_status(:found) # 302
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "更新成功し、302を返す" do
        patch life_event_path(life_event), params: { life_event: valid_params_for_update }
        expect(response).to have_http_status(:found) # 302

        life_event.reload
        expect(life_event.amount).to eq 20
      end
    end

    context "無効なパラメータの場合" do
      it "更新失敗し、422を返す" do
        patch life_event_path(life_event), params: { life_event: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "DELETE /destroy" do
    context "削除したいデータが存在する場合" do
      it "削除成功し、302を返す" do
        delete life_event_path(life_event)
        expect(response).to have_http_status(:found)  # 302
      end
    end

    context "削除したいデータが存在しない場合" do
      it "削除失敗し、302を返す" do
        delete life_event_path(-1) # 存在しないID
        expect(response).to have_http_status(:found)  # 302
      end
    end
  end
end
