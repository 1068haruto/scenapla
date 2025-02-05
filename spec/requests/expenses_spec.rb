require 'rails_helper'

RSpec.describe "Expenses", type: :request do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:expense) { create(:expense, user: user, simulation: simulation) }

  let(:valid_params) { attributes_for(:expense) }    # factorybotデータ
  let(:invalid_params) { { housing_expense: nil } }  # 無効なデータ(その他属性はfactorybot通り)

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページ表示し200を返す" do
      get expenses_path
      expect(response).to have_http_status(:success)  # 200
    end
  end

  describe "POST /create_or_update" do
    context "正しいフォーム入力で保存/更新が成功した場合" do
      it "302を返す" do
        post create_or_update_expenses_path, params: { expense: valid_params }
        expect(response).to have_http_status(:found)  # 302
      end
    end

    context "不正なフォーム入力で保存/更新が失敗した場合" do
      it "402を返す" do
        post create_or_update_expenses_path, params: { expense: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)  # 422
      end
    end
  end

  describe "POST /update_simulation_data" do
    context "成功した場合" do
      before do
        allow_any_instance_of(Simulation).to receive(:update_expense_data!).and_return(true)
      end

      it "user_assets_pathへリダイレクトする" do
        post update_simulation_data_expenses_path
        expect(response).to have_http_status(:found)  # 302
      end
    end

    context "失敗した場合" do
      before do
        allow_any_instance_of(Simulation).to receive(:update_expense_data!).and_return(false)
      end

      it "expenses_pathリダイレクトする" do
        post update_simulation_data_expenses_path
        expect(response).to have_http_status(:found)  # 302
      end
    end
  end
end
