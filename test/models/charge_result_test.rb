require "test_helper"

class ChargeResultTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  # 
  
  

  test "should belong to bulk charge" do
    bulk_charge = BulkCharge.new(status: :pending)
    bulk_charge.csv_file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/bulk-exercise.csv")),
      filename: "bulk-exercise.csv",
      content_type: "text/csv"
    )
    assert bulk_charge.save, "Failed to save the bulk charge with a csv file"
    charge_result = ChargeResult.create!(bulk_charge: bulk_charge)

    assert_equal bulk_charge, charge_result.bulk_charge
  end
end
