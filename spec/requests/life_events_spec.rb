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
    it "ページを表示(200)" do
      get life_events_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "有効なパラメータの場合" do
      it "作成成功(302)" do
        post life_events_path, params: { life_event: valid_params }
        expect(response).to have_http_status(:found)
      end
    end

    context "無効なパラメータの場合" do
      it "作成失敗(422)" do
        post life_events_path, params: { life_event: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    context "データが存在する場合" do
      it "フォームを表示(200)" do
        get edit_life_event_path(life_event)
        expect(response).to have_http_status(:success)
      end
    end

    context "データがしない場合" do
      it "フォームを表示しない(302)" do
        get edit_life_event_path(-1)  # 存在しないID
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "更新成功(302)" do
        patch life_event_path(life_event), params: { life_event: valid_params_for_update }
        expect(response).to have_http_status(:found)

        life_event.reload
        expect(life_event.amount).to eq 20
      end
    end

    context "無効なパラメータの場合" do
      it "更新失敗(422)" do
        patch life_event_path(life_event), params: { life_event: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    context "データが存在する場合" do
      it "削除成功(302)" do
        delete life_event_path(life_event)
        expect(response).to have_http_status(:found)
      end
    end

    context "削除したいデータが存在しない場合" do
      it "削除失敗(302)" do
        delete life_event_path(-1) # 存在しないID
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'POST /update_sim_data' do
    let(:data_updater) { instance_double(DataUpdater::SimulationDataUpdater) }
    let(:life_event_data) { {
      real_event_data: "test real_event_data",
      ideal_event_data: "test ideal_event_data"
    } }

    before do
      allow(DataUpdater::SimulationDataUpdater).to receive(:new).with(user).and_return(data_updater)
    end

    context '成功した場合' do
      before do
        allow(data_updater).to receive(:update_life_event).and_return(true)
        post update_sim_life_events_path
      end

      it 'scenarios_pathへリダイレクトする' do
        expect(response).to redirect_to(scenarios_path)
      end
    end

    context '失敗した場合' do
      before do
        allow(data_updater).to receive(:update_life_event).and_return(false)
        post update_sim_life_events_path
      end

      it 'life_events_pathへリダイレクトする' do
        expect(response).to redirect_to(life_events_path)
      end
    end
  end
end
