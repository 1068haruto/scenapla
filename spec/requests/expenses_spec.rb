require 'rails_helper'

RSpec.describe "Expenses", type: :request do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:expense) { create(:expense, user: user, simulation: simulation) }

  # パラメータ
  let(:valid_params) { attributes_for(:expense) }
  let(:valid_params_for_update) { { housing_expenses: 20 } }
  let(:invalid_params) { { housing_expenses: -20 } }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示(200)" do
      get expenses_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "他のデータが存在する場合" do
      it "作成成功し、古いデータを削除(302)" do
        oldExpense = create(:expense, user: user, simulation: simulation)
        post expenses_path, params: { expense: valid_params }

        expect(user.expenses.count).to eq(1)  # 保存済が1件(新データ)のみを期待
        expect(Expense.find_by(id: oldExpense.id)).to be_nil  # 古いデータが削除されるを期待
        expect(response).to have_http_status(:found)
      end
    end

    context "他のデータが存在しない場合" do
      it "作成成功(302)" do
        post expenses_path, params: { expense: valid_params }

        expect(user.expenses.count).to eq(1)  # 保存済が1件(新データ)のみを期待
        expect(response).to have_http_status(:found)
      end
    end

    context "無効なパラメータの場合" do
      it "作成失敗(422)" do
        post expenses_path, params: { expense: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    context "データが存在する場合" do
      it "フォームを表示(200)" do
        get edit_expense_path(expense)
        expect(response).to have_http_status(:success)
      end
    end

    context "データが存在しない場合" do
      it "フォームを表示しない(302)" do
        get edit_expense_path(-1) # 存在しないID
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "更新成功(302)" do
        patch expense_path(expense), params: { expense: valid_params_for_update }
        expect(response).to have_http_status(:found)

        expense.reload
        expect(expense.housing_expenses).to eq(20)
      end
    end

    context "無効なパラメータの場合" do
      it "更新失敗(422)" do
        patch expense_path(expense), params: { expense: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    context "データが存在する場合" do
      it "削除成功(302)" do
        delete expense_path(expense)
        expect(response).to have_http_status(:found)
      end
    end

    context "データが存在しない場合" do
      it "削除失敗(302)" do
        delete expense_path(-1) # 存在しないID
        expect(response).to have_http_status(:found)
      end
    end
  end
end
