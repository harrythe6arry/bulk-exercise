class ChangeStatusToIntegerInBulkCharges < ActiveRecord::Migration[7.0]
  def change
    change_column :bulk_charges, :status, :integer, default: 0, using: 'status::integer'
  end
end