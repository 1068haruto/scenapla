require 'rails_helper'

RSpec.describe "LifePlans", type: :request do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }
  let!(:memo) { create(:memo, user: user) } # 既存メモ（更新テストで使用）

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示（200）" do
      get life_plans_path
      expect(response).to have_http_status(:success)
    end
  end

  # advice関連（後ほど実装）

  # memo関連
  describe "POST /life_plans/save_memo" do
    context "新規で保存する場合" do
      let(:new_age_group) { 30 }
      let(:new_content) { "新規のメモ内容" }
      let(:new_params) { { memo: { age_group: new_age_group, content: new_content } } }

      it "保存成功し、メモが1件増え、リダイレクト（302）" do
        expect { post save_memo_life_plans_path, params: new_params }.to change(user.memos, :count).by(1)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(life_plans_path)
        created_memo = user.memos.find_by(age_group: new_age_group)
        expect(created_memo.content).to eq(new_content)
      end
    end

    context "既存を更新する場合" do
      let(:age_group) { 20 } # factoryデータ指定
      let(:updated_content) { "更新後のメモ内容" }
      let(:updated_params) { { memo: { age_group: age_group, content: updated_content } } }

      it "更新成功し、メモ件数は変わらず、リダイレクト（302）" do
        expect { post save_memo_life_plans_path, params: updated_params }.to change(user.memos, :count).by(0)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(life_plans_path)
        expect(memo.reload.content).to eq(updated_content)
      end
    end
  end
end
