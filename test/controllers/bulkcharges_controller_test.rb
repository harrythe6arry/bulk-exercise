require "test_helper"

class BulkchargesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  test "should get index" do
    get bulkcharges_url
    assert_response :success
    assert_select "h1", "Bulk Charges total CSV files "
  end
end
