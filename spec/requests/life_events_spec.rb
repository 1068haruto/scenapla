require 'rails_helper'

RSpec.describe "LifeEvents", type: :request do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:life_event) { create(:life_event, user: user, simulation: simulation) }

  let(:valid_params) { attributes_for(:life_event) } # 有効なデータ
  let(:invalid_params) { { event_date: nil } }  # 無効なデータ

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示し200を返す" do
      get life_events_path
      expect(response).to have_http_status(:success)  # 200
    end
  end

  describe "GET /new" do
    it "ページを表示し200を返す" do
      get new_life_event_path
      expect(response).to have_http_status(:success)  # 200
    end
  end

  describe "POST /create" do
    context "有効なフォーム入力の場合" do
      it "new_life_event_pathにリダイレクトし302を返す" do
        post life_events_path, params: { life_event: valid_params }
        expect(response).to have_http_status(:found)  # 302
      end
    end

    context "不正なフォーム入力の場合" do
      it "422を返す" do
        post life_events_path, params: { life_event: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)  # 422
      end
    end
  end

  describe "DELETE /destroy" do
    context "イベントデータがあり、削除成功した場合" do
      it "new_life_event_pathにリダイレクトし302を返す" do
        delete life_event_path(life_event)
        expect(response).to have_http_status(:found)  # 302
      end
    end

    context "イベントデータがなく、削除失敗した場合" do
      it "404を返す" do
        delete life_event_path(-1) # 存在しないID
        expect(response).to have_http_status(:not_found)  # 404
      end
    end
  end

  describe "POST /update_simulation_data" do
    context "成功した場合" do
      before do
        allow_any_instance_of(Simulation).to receive(:update_life_event_data!).and_return(true)
      end

      it "scenarios_pathにリダイレクトし302を返す" do
        post update_simulation_data_life_events_path
        expect(response).to have_http_status(:found)  # 302
      end
    end

    context "失敗した場合" do
      before do
        allow_any_instance_of(Simulation).to receive(:update_life_event_data!).and_return(false)
      end

      it "new_life_event_pathにリダイレクトし302を返す" do
        post update_simulation_data_life_events_path
        expect(response).to have_http_status(:found)  # 302
      end
    end
  end
end
