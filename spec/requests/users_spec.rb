require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /users/:id" do
    it "ページを表示し200を返す" do
      get user_path(user)
      expect(response).to have_http_status(:success)  # 200
    end
  end
end
