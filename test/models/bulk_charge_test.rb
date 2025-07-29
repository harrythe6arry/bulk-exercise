require "test_helper"

class BulkChargeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  

  test "should not save bulk charge without csv file" do
    bulk_charge = BulkCharge.new
    assert_not bulk_charge.save, "Saved the bulk charge without a csv file"
  end
  test "should save bulk charge with csv file" do
    bulk_charge = BulkCharge.new(status: :pending)
    bulk_charge.csv_file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/bulk-exercise.csv")),
      filename: "bulk-exercise.csv",
      content_type: "text/csv"
    )
    assert bulk_charge.save, "Failed to save the bulk charge with a csv file"
  end

  test "should validate presence of csv file" do
    bulk_charge = BulkCharge.new
    bulk_charge.valid?
    assert_includes bulk_charge.errors[:csv_file], "can't be blank", "CSV file presence validation failed"
  end

  test "should have one attached csv file" do
    bulk_charge = BulkCharge.new(status: :pending)
    bulk_charge.csv_file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/bulk-exercise.csv")),
      filename: "bulk-exercise.csv",
      content_type: "text/csv"
    )
    assert bulk_charge.csv_file.attached?, "CSV file is not attached"
  end
end
