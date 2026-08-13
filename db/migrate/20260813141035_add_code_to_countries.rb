class AddCodeToCountries < ActiveRecord::Migration[8.1]
  def change
    add_column :countries, :code, :string, limit: 2, null: false
    add_index :countries, :code, unique: true
  end
end
