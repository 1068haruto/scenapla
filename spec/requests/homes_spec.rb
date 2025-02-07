require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /" do
    it "ページを表示し200を返す" do
      get root_path
      expect(response).to have_http_status(:success)  # 200
    end
  end
end
