require 'rails_helper'

RSpec.describe "Incomes", type: :request do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:income) { create(:income, user: user, simulation: simulation) }

  # パラメータ
  let(:valid_params) { attributes_for(:income) }
  let(:valid_params_for_update) { { monthly_income: 20 } }
  let(:invalid_params) { { monthly_income: -20 } }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示し200を返す" do
      get incomes_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "有効なパラメータの場合" do
      it "作成成功し、302を返す" do
        post incomes_path, params: { income: valid_params }
        expect(response).to have_http_status(:found)
      end
    end

    context "無効なパラメータの場合" do
      it "作成失敗し、422返す" do
        post incomes_path, params: { income: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    context "編集したいデータが存在する場合" do
      it "編集フォームを表示し、200を返す" do
        get edit_income_path(income)
        expect(response).to have_http_status(:success) # 200
      end
    end

    context "編集したいデータが存在しない場合" do
      it "編集フォームを表示せず、302を返す" do
        get edit_income_path(-1) # 存在しないID
        expect(response).to have_http_status(:found) # 302
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "更新成功し、302を返す" do
        patch income_path(income), params: { income: valid_params_for_update }
        expect(response).to have_http_status(:found) # 302

        income.reload
        expect(income.monthly_income).to eq 20
      end
    end

    context "無効なパラメータの場合" do
      it "更新失敗し、422を返す" do
        patch income_path(income), params: { income: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "DELETE /destroy" do
    context "削除したいデータが存在する場合" do
      it "削除成功し、302を返す" do
        delete income_path(income)
        expect(response).to have_http_status(:found)
      end
    end

    context "削除したいデータが存在しない場合" do
      it "削除失敗し、302を返す" do
        delete income_path(-1) # 存在しないID
        expect(response).to have_http_status(:found) # 302
      end
    end
  end
end
