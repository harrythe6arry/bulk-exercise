class CreateBulkCharges < ActiveRecord::Migration[8.0]
  def change
    create_table :bulk_charges do |t|
      t.string :status

      t.timestamps
    end
  end
end
