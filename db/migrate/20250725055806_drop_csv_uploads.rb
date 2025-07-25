class DropCsvUploads < ActiveRecord::Migration[8.0]
  def change
    drop_table :csv_uploads
  end
end