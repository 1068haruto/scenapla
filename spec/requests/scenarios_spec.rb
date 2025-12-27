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

  describe "POST /update_scenarios_lifespan" do
    let(:service_class) { DataUpdater::DualDataUpdater }

    it "更新成功（302）" do
      # DualDataUpdaterのモック
      dual_updater_service = instance_double(service_class, call: true)
      allow(service_class).to receive(:new).with(user).and_return(dual_updater_service)

      post update_scenarios_lifespan_scenarios_path

      expect(service_class).to have_received(:new).with(user)
      expect(dual_updater_service).to have_received(:call)
      expect(response).to redirect_to(scenarios_path)
    end

    it "更新失敗（302）" do
      # DualDataUpdaterのモック
      dual_updater_service = instance_double(service_class, call: false)
      allow(service_class).to receive(:new).with(user).and_return(dual_updater_service)

      post update_scenarios_lifespan_scenarios_path

      expect(service_class).to have_received(:new).with(user)
      expect(dual_updater_service).to have_received(:call)
      expect(response).to redirect_to(scenarios_path)
    end
  end
end
