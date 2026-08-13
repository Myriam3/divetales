class CreateCountries < ActiveRecord::Migration[8.1]
  def change
    create_table :countries do |t|
      t.string :name, null: false, limit: 150

      t.timestamps
    end
  end
end
