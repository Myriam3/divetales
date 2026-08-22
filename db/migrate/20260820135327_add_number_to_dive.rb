class AddNumberToDive < ActiveRecord::Migration[8.1]
  def change
    add_column :dives, :dive_number, :integer
    add_index :dives, :dive_number, unique: true
  end
end
