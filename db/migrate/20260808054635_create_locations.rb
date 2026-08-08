class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.references :country, null: false, foreign_key: true
      t.string :name, null: false, limit: 150

      t.timestamps
    end
  end
end
