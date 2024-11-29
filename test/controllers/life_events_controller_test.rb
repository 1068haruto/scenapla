require "test_helper"

class LifeEventsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get life_events_index_url
    assert_response :success
  end
end
