class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :url_name

      t.timestamps
    end
        add_index :accounts, :url_name, unique: true
  end

  def down 
    drop_table :accounts
    remove_index :accounts, :url_name
  end
end
