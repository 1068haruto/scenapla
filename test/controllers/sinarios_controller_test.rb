require "test_helper"

class SinariosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sinarios_index_url
    assert_response :success
  end
end
