require 'rails_helper'

RSpec.describe "Expenses", type: :request do
  let(:user) { create(:user) }
  let(:simulation) { create(:simulation, user: user) }
  let(:expense) { create(:expense, user: user, simulation: simulation) }

  let(:valid_params) { attributes_for(:expense) }    # factorybotデータ
  let(:invalid_params) { { housing_expenses: nil } }  # 無効なデータ(その他属性はfactorybot通り)

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
    context "既にデータがある状態で新規作成する場合" do
      it "新しいデータ作成後、古いデータが削除され、302を返す" do
        old_expense = create(:expense, user: user, simulation: simulation)
        post expenses_path, params: { expense: valid_params }

        expect(user.expenses.count).to eq(1)                  # 保存済みデータが1件(新しいデータ)のみとなることを期待
        expect(Expense.find_by(id: old_expense.id)).to be_nil # 古いデータが削除されたことを確認
        expect(response).to have_http_status(:found)          # 302
      end
    end

    context "データが存在しない状態で新規作成する場合" do
      it "正常にデータが1件作成される" do
        post expenses_path, params: { expense: valid_params }

        expect(user.expenses.count).to eq(1)                  # 保存済みデータが1件(新しいデータ)のみとなることを期待
        expect(response).to have_http_status(:found)          # 302
      end
    end

    context "無効なフォーム入力の場合" do
      it "作成失敗し、422を返す" do
        post expenses_path, params: { expense: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "GET /edit" do
    context "データが存在する場合" do
      it "編集フォームを表示し、200を返す" do
        get edit_expense_path(expense)
        expect(response).to have_http_status(:success) # 200
      end
    end

    context "データが存在しない場合" do
      it "404を返す" do
        get edit_expense_path(-1) # 存在しないID
        expect(response).to have_http_status(:not_found) # 404
      end
    end
  end

  describe "PATCH /update" do
    let(:update_params) do
      {
        housing_expenses: 5.5,
        repayment_date: Date.new(2040, 1, 1),
        living_expenses: 3.2,
        monthly_premiums: 1.8,
        other_expenses: 0.5
      }
    end

    context "有効なパラメータの場合" do
      it "更新され、302を返す" do
        patch expense_path(expense), params: { expense: update_params }
        expect(response).to have_http_status(:found)

        expense.reload
        expect(expense.housing_expenses).to eq(5.5)
        expect(expense.repayment_date).to eq(Date.new(2040, 1, 1))
        expect(expense.living_expenses).to eq(3.2)
        expect(expense.monthly_premiums).to eq(1.8)
        expect(expense.other_expenses).to eq(0.5)
      end
    end

    context "無効なパラメータの場合" do
      it "更新されず、422を返す" do
        patch expense_path(expense), params: { expense: { housing_expenses: -1 } }
        expect(response).to have_http_status(:unprocessable_entity) # 422
      end
    end
  end

  describe "DELETE /destroy" do
    context "データが存在する場合" do
      it "削除成功し、302を返す" do
        delete expense_path(expense)
        expect(response).to have_http_status(:found)
      end
    end

    context "データが存在しない場合" do
      it "削除失敗し、404を返す" do
        delete expense_path(-1) # 存在しないID
        expect(response).to have_http_status(:not_found) # 404
      end
    end
  end
end
