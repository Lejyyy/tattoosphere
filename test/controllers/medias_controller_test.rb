require "test_helper"

class MediasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get medias_index_url
    assert_response :success
  end
end
