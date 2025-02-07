require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /static_pages/terms" do
    it "ページを表示し200を返す" do
      get static_pages_terms_path
      expect(response).to have_http_status(:success)  # 200
    end
  end

  describe "GET /static_pages/privacy" do
    it "ページを表示し200を返す" do
      get static_pages_privacy_path
      expect(response).to have_http_status(:success)  # 200
    end
  end
end
