require 'rails_helper'

RSpec.describe "Memos", type: :request do
  let!(:user) { create(:user) }
  let(:memo) { create(:memo, user: user) }
  let(:valid_params) { { memo: { age_group: 20, content: "メモの内容" } } }
  let(:invalid_params) { { memo: { age_group: "", content: "メモの内容" } } }

  before do
    sign_in user
  end

  describe "POST /memos" do
    context "age_groupに紐付くメモを保存する場合" do
      it "200を返す" do
        post memos_path, params: valid_params, as: :json
        expect(response).to have_http_status(:success)  # 200
      end
    end

    context "age_groupが存在しないメモを保存する場合" do
      it "422を返す" do
        post memos_path, params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)  # 422
      end
    end
  end

  describe "PATCH /memos/:id" do
    context "age_groupに紐ずく既存メモを更新する場合" do
      it "200を返す" do
        patch memo_path(memo), params: valid_params, as: :json
        expect(response).to have_http_status(:success)  # 200
      end
    end

    context "age_groupが存在しないメモを更新する場合" do
      it "422を返す" do
        patch memo_path(memo), params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)  # 422
      end
    end
  end
end
