require 'rails_helper'

RSpec.describe "Scenarios", type: :request do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:scenario) { create(:scenario, user: user, simulation: simulation) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示し200を返す" do
      get scenarios_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /update_scenarios" do
    it "scenarios_pathにリダイレクトし302を返す" do
      allow_any_instance_of(Scenario).to receive(:update_scenario_data!).and_return(true)

      post update_scenarios_scenarios_path
      expect(response).to have_http_status(:found)  # 302
      expect(response).to redirect_to(scenarios_path)
    end

    it "scenarios_pathにリダイレクトし302を返す" do
      allow_any_instance_of(Scenario).to receive(:update_scenario_data!).and_return(false)

      post update_scenarios_scenarios_path
      expect(response).to have_http_status(:found)  # 302
      expect(response).to redirect_to(scenarios_path)
    end
  end
end