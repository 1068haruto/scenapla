require "test_helper"

class UserAssetsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_assets_index_url
    assert_response :success
  end
end
