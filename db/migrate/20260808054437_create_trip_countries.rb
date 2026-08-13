class CreateTripCountries < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_countries do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
