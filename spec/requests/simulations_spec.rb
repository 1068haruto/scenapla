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
        allow(Income).to receive(:generate_income_data_for).and_return(income_data)
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
        allow(Income).to receive(:generate_income_data_for).and_return(income_data)
        allow_any_instance_of(Simulation).to receive(:update!).and_return(false)
        post update_income_data_simulation_path
      end

      it 'incomes_pathへリダイレクトする' do
        expect(response).to have_http_status(:found) # 302
        expect(response).to redirect_to(incomes_path)
      end
    end
  end
end
