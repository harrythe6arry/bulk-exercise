require "test_helper"

class BulkchargesControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess

  def setup
    @bulk_charge = BulkCharge.create!(status: :pending)
    @bulk_charge.csv_file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/bulk-exercise.csv")),
      filename: "bulk-exercise.csv",
      content_type: "text/csv"
    )
  end

  test "should get index" do
    get bulkcharges_path
    assert_response :success
  end

  test "should get new" do
    get new_bulkcharge_path
    assert_response :success
  end

 test "should create bulk charge" do
  assert_difference('BulkCharge.count') do
    post bulkcharges_path, params: { bulk_charge: { csv_file: fixture_file_upload(Rails.root.join("test/fixtures/files/bulk-exercise.csv"), "text/csv") } }
  end
  assert_redirected_to bulkcharge_path(BulkCharge.last)
  assert_equal 'Bulk charge was successfully created.', flash[:notice]
end


test "should show bulk charge" do
  get bulkcharge_path(@bulk_charge)
  assert_response :success
end


end