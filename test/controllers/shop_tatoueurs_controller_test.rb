require "test_helper"

class ShopTatoueursControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get shop_tatoueurs_create_url
    assert_response :success
  end

  test "should get destroy" do
    get shop_tatoueurs_destroy_url
    assert_response :success
  end
end
