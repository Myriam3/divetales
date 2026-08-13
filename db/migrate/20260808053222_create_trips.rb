class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.string :title, null: false, limit: 150
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.text :info, limit: 500

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
