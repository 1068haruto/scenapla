require 'rails_helper'

RSpec.describe "Incomes", type: :request do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:income) { create(:income, user: user, simulation: simulation) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示し200を返す" do
      get incomes_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "編集フォームを表示し200を返す" do
      get edit_income_path(income)
      expect(response).to have_http_status(:success)
    end

    it "存在しないincomeなら404を返す" do
      get edit_income_path(-1) # 存在しないID
      expect(response).to have_http_status(:not_found) # 404
    end
  end

  describe "POST /create" do
    let(:valid_params) do
      { income: attributes_for(:income) }
    end

    it "保存成功の場合は、302を返す" do
      valid_params = { income: attributes_for(:income) }
      post incomes_path, params: valid_params
      expect(response).to have_http_status(:found)
    end

    it "保存失敗の場合は、422返す" do
      allow_any_instance_of(Income).to receive(:save).and_return(false)
      post incomes_path, params: valid_params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /update" do
    let(:update_params) do
      {
        income: {
          monthly_income: 50.0,
          yearly_bonus: 100.0,
          person_type: "本人",
          retirement_date: Date.new(2035),
          retirement_pay: 300.0
        }
      }
    end

    it "更新成功時は302を返す" do
      patch income_path(income), params: update_params
      expect(response).to have_http_status(:found)

      income.reload
      expect(income.monthly_income).to eq 50.0
      expect(income.yearly_bonus).to eq 100.0
      expect(income.person_type).to eq "本人"
      expect(income.retirement_date).to eq Date.new(2035)
      expect(income.retirement_pay).to eq 300.0
    end

    it "更新失敗時は422を返す" do
      allow_any_instance_of(Income).to receive(:update).and_return(false)
      patch income_path(income), params: update_params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /destroy" do
    it "削除成功の場合は、302を返す" do
      delete income_path(income)
      expect(response).to have_http_status(:found)
    end

    it "削除失敗の場合は、404を返す" do
      delete income_path(-1) # 存在しないID
      expect(response).to have_http_status(:not_found) # 404
    end
  end
end
