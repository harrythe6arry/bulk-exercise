class CreateChargeResults < ActiveRecord::Migration[8.0]
  def change
    create_table :charge_results do |t|
      t.references :bulk_charge, null: false, foreign_key: true
      t.integer :row_number
      t.string :status
      t.string :omise_charge_id
      t.json :token_response
      t.json :charge_response

      t.timestamps
    end
  end
end
