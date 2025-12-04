require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /static_pages/index" do
    it "ページを表示する（200）" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
  describe "GET /static_pages/terms" do
    it "ページを表示する（200）" do
      get terms_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /static_pages/privacy" do
    it "ページを表示する（200）" do
      get privacy_path
      expect(response).to have_http_status(:success)
    end
  end
end
