require 'rails_helper'

RSpec.describe "LifePlans", type: :request do
  let!(:user) { create(:user) }
  let!(:simulation) { create(:simulation, user: user) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "ページを表示し200を返す" do
      get life_plans_path
      expect(response).to have_http_status(:success)  # 200
    end
  end
end
