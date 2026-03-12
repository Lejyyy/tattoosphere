require "test_helper"

class PortfolioItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get portfolio_items_index_url
    assert_response :success
  end

  test "should get show" do
    get portfolio_items_show_url
    assert_response :success
  end

  test "should get new" do
    get portfolio_items_new_url
    assert_response :success
  end

  test "should get edit" do
    get portfolio_items_edit_url
    assert_response :success
  end
end
