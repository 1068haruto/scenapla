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

  describe "POST /update_simulation_data" do
    it "成功した場合はexpenses_pathにリダイレクトする" do
      allow_any_instance_of(Simulation).to receive(:update_income_data!).and_return(true)
      post update_simulation_data_incomes_path
      expect(response).to have_http_status(:found)  # 302
    end

    it "失敗した場合はincomes_pathにリダイレクトする" do
      allow_any_instance_of(Simulation).to receive(:update_income_data!).and_return(false)
      post update_simulation_data_incomes_path
      expect(response).to have_http_status(:found)  # 302
    end
  end
end
