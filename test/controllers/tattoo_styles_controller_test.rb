require "test_helper"

class TattooStylesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tattoo_styles_index_url
    assert_response :success
  end
end
