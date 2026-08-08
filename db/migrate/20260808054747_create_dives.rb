class CreateDives < ActiveRecord::Migration[8.1]
  def change
    create_table :dives do |t|
      # From user
      t.string :dive_site_name, null: false, default: ""
      t.references :trip, null: false, foreign_key: true
      t.text :note, limit: 500

      # From user (or API with coordinates)
      t.references :location, null: false, foreign_key: true
      t.integer :type, array: true, default: [] # enum

      # From dive data or manually
      t.date :date, null: false
      t.float :max_depth
      t.float :avg_depth
      t.text :depth_over_time, default: ""
      t.integer :duration
      t.float :max_temp
      t.float :min_temp
      t.float :avg_temp
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
  end
end
