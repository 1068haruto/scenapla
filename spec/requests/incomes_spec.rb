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
    it "ページを表示(200)" do
      get incomes_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "有効なパラメータの場合" do
      it "作成成功(302)" do
        post incomes_path, params: { income: valid_params }
        expect(response).to have_http_status(:found)
      end
    end

    context "無効なパラメータの場合" do
      it "作成失敗(422)" do
        post incomes_path, params: { income: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    context "データが存在する場合" do
      it "フォームを表示(200)" do
        get edit_income_path(income)
        expect(response).to have_http_status(:success)
      end
    end

    context "データが存在しない" do
      it "フォームを表示しない(302)" do
        get edit_income_path(-1) # 存在しないID
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "更新成功(302)" do
        patch income_path(income), params: { income: valid_params_for_update }
        expect(response).to have_http_status(:found)

        income.reload
        expect(income.monthly_income).to eq 20
      end
    end

    context "無効なパラメータの場合" do
      it "更新失敗(422)" do
        patch income_path(income), params: { income: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    context "データが存在する場合" do
      it "削除成功(302)" do
        delete income_path(income)
        expect(response).to have_http_status(:found)
      end
    end

    context "データが存在しない場合" do
      it "削除失敗(302)" do
        delete income_path(-1) # 存在しないID
        expect(response).to have_http_status(:found)
      end
    end
  end
end
