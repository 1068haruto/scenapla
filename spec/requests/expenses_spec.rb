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
    it "ページ表示し200を返す" do
      get expenses_path
      expect(response).to have_http_status(:success)  # 200
    end
  end

  describe "POST /create" do
    context "既に他のデータが存在する場合" do
      it "新規作成し、古いデータを削除し、302を返す" do
        old_expense = create(:expense, user: user, simulation: simulation)
        post expenses_path, params: { expense: valid_params }

        expect(user.expenses.count).to eq(1)                  # 保存済みデータが1件(新しいデータ)のみとなるを期待
        expect(Expense.find_by(id: old_expense.id)).to be_nil # 古いデータが削除されているを期待
        expect(response).to have_http_status(:found)          # 302
      end
    end

    context "他のデータが存在しない場合" do
      it "新規作成し、302を返す" do
        post expenses_path, params: { expense: valid_params }

        expect(user.expenses.count).to eq(1)                  # 保存済みデータが1件(新しいデータ)のみとなるを期待
        expect(response).to have_http_status(:found)          # 302
      end
    end

    context "無効なパラメータの場合" do
      it "作成失敗し、422を返す" do
        post expenses_path, params: { expense: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "GET /edit" do
    context "編集したいデータが存在する場合" do
      it "編集フォームを表示し、200を返す" do
        get edit_expense_path(expense)
        expect(response).to have_http_status(:success) # 200
      end
    end

    context "編集したいデータが存在しない場合" do
      it "編集フォームを表示せず、302を返す" do
        get edit_expense_path(-1) # 存在しないID
        expect(response).to have_http_status(:found) # 302
      end
    end
  end

  describe "PATCH /update" do
    context "有効なパラメータの場合" do
      it "更新成功し、302を返す" do
        patch expense_path(expense), params: { expense: valid_params_for_update }
        expect(response).to have_http_status(:found)

        expense.reload
        expect(expense.housing_expenses).to eq(20)
      end
    end

    context "無効なパラメータの場合" do
      it "更新失敗し、422を返す" do
        patch expense_path(expense), params: { expense: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "DELETE /destroy" do
    context "削除したいデータが存在する場合" do
      it "削除成功し、302を返す" do
        delete expense_path(expense)
        expect(response).to have_http_status(:found)
      end
    end

    context "削除したいデータが存在しない場合" do
      it "削除失敗し、302を返す" do
        delete expense_path(-1) # 存在しないID
        expect(response).to have_http_status(:found) # 302
      end
    end
  end
end
