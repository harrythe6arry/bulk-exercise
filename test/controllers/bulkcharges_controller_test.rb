require "test_helper"
require "minitest/autorun"

class BulkchargesControllerTest <  ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    @bulk_charge = BulkCharge.create!(status: :pending, csv_file: fixture_file_upload("files/bulk-exercise.csv", "text/csv"))
  end

  test "should get index" do
    get bulkcharges_path
    assert_response :success
    # assert_select "h1", "Bulk Charges"
  end

  # test "should create bulk charge" do
  #   assert_difference('BulkCharge.count', 1) do
  #     post bulkcharges_path, params: { bulk_charge: { csv_file: fixture_file_upload("test.csv", "text/csv") } }
  #   end
  #   assert_redirected_to bulkcharge_path(BulkCharge.last)
  # end

  # test "should show bulk charge" do
  #   get bulkcharge_path(@bulk_charge)
  #   assert_response :success
  #   assert_select "h1", "Bulk Charge Details"
  # end

  # test "should preview CSV" do
  #   get csv_preview_bulkcharge_path(@bulk_charge)
  #   assert_response :success
  #   assert_select "h2", "CSV Preview"
  # end

  # test "should handle job enqueuing" do
  #   perform_enqueued_jobs do
  #     ChargeCsvJob.perform_later(@bulk_charge.id)
  #     assert_enqueued_with(job: ChargeCsvJob, args: [@bulk_charge.id])
  #   end
  # end
end
  