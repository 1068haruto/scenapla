require 'rails_helper'


RSpec.describe "Users::Confirmations", type: :request do
  let(:user) { create(:user, confirmed_at: nil) }
  
  describe "GET /users/confirmation" do
    before do
      user.send_confirmation_instructions  # 新規登録後に確認メール送信処理
      @token = user.confirmation_token     # 確認トークンを取得
    end

    it "確認後、正しくリダイレクトする" do
      get user_confirmation_path(confirmation_token: @token)
      expect(response).to have_http_status(:found)  # 302
      expect(response).to redirect_to(dashboard_index_path)
    end

    it "状態が確認済に正しく変わる" do
      expect {
        get user_confirmation_path(confirmation_token: @token)
        user.reload  # ユーザーを再度読み込み
      }.to change { user.confirmed? }.from(false).to(true)  # 確認済の状態となる
    end
  end
end