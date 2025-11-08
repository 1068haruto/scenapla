require 'rails_helper'

RSpec.describe "Simulations", type: :request do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }

  before do
    sign_in user
  end

  describe 'POST /simulation/update_income_data' do
    let(:income_data) { { income_data: "test income data" } }

    context '成功した場合' do
      before do
        allow(Income).to receive(:generate_income_data).and_return(income_data)
        allow_any_instance_of(Simulation).to receive(:update!).and_return(true)
        post update_income_data_simulation_path
      end

      it 'expenses_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(expenses_path)
      end
    end

    context '失敗した場合' do
      before do
        allow(Income).to receive(:generate_income_data).and_return(income_data)
        allow_any_instance_of(Simulation).to receive(:update).and_return(false)
        post update_income_data_simulation_path
      end

      it 'incomes_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(incomes_path)
      end
    end
  end

  describe 'POST /simulation/update_expense_data' do
    let(:expense_data) { { expense_data: "test expense data" } }

    context '成功した場合' do
      before do
        allow(Expense).to receive(:generate_expense_data_for).and_return(expense_data)
        allow_any_instance_of(Simulation).to receive(:update).and_return(true)
        post update_expense_data_simulation_path
      end

      it 'user_assets_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(user_assets_path)
      end
    end

    context '失敗した場合' do
      before do
        allow(Expense).to receive(:generate_expense_data_for).and_return(expense_data)
        allow_any_instance_of(Simulation).to receive(:update).and_return(false)
        post update_expense_data_simulation_path
      end

      it 'expenses_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(expenses_path)
      end
    end
  end

  describe 'POST /simulation/update_user_asset_data' do
    let(:user_asset_data) { { user_asset_data: "test user_asset data" } }

    context '成功した場合' do
      before do
        allow(UserAsset).to receive(:generate_user_asset_data_for).and_return(user_asset_data)
        allow_any_instance_of(Simulation).to receive(:update!).and_return(true)
        post update_user_asset_data_simulation_path
      end

      it 'life_events_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(life_events_path)
      end
    end

    context '失敗した場合' do
      before do
        allow(UserAsset).to receive(:generate_user_asset_data_for).and_return(user_asset_data)
        allow_any_instance_of(Simulation).to receive(:update).and_return(false)
        post update_user_asset_data_simulation_path
      end

      it 'user_assets_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(user_assets_path)
      end
    end
  end

  describe 'POST /simulation/update_life_event_data' do
    let(:life_event_data) { { real_event_data: "test real event data", ideal_event_data: "test ideal event data" } }

    context '成功した場合' do
      before do
        allow(LifeEvent).to receive(:generate_life_event_data_for).and_return(life_event_data)
        allow_any_instance_of(Simulation).to receive(:update!).and_return(true)
        post update_life_event_data_simulation_path
      end

      it 'scenarios_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(scenarios_path)
      end
    end

    context '失敗した場合' do
      before do
        allow(LifeEvent).to receive(:generate_life_event_data_for).and_return(life_event_data)
        allow_any_instance_of(Simulation).to receive(:update).and_return(false)
        post update_life_event_data_simulation_path
      end

      it 'life_events_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(life_events_path)
      end
    end
  end
end
