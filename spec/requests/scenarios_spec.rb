require 'rails_helper'

RSpec.describe "Scenarios", type: :request do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:asset_lifespan) { create(:asset_lifespan, user: user, simulation: simulation) }
  # 現実と理想のシナリオ（update_scenarios内部で参照）
  let!(:real_scenario) { create(:scenario, :real, user: user, simulation: simulation) }
  let!(:ideal_scenario) { create(:scenario, :ideal, user: user, simulation: simulation) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示(200)" do
      get scenarios_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /update_scenarios" do
    it "更新成功（302）" do
      allow(Scenario).to receive(:update_scenarios).and_return(true)
      post update_scenarios_scenarios_path

      expect(Scenario).to have_received(:update_scenarios).with(user)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(scenarios_path)
    end

    it "更新失敗（302）" do
      allow(Scenario).to receive(:update_scenarios).and_return(false)
      post update_scenarios_scenarios_path

      expect(Scenario).to have_received(:update_scenarios).with(user)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(scenarios_path)
    end
  end
end
