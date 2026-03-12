require "test_helper"

class TatoueursControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tatoueurs_index_url
    assert_response :success
  end

  test "should get show" do
    get tatoueurs_show_url
    assert_response :success
  end

  test "should get new" do
    get tatoueurs_new_url
    assert_response :success
  end

  test "should get edit" do
    get tatoueurs_edit_url
    assert_response :success
  end
end
