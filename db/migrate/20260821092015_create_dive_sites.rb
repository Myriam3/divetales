class CreateDiveSites < ActiveRecord::Migration[8.1]
  def change
    create_table :dive_sites do |t|
      t.string :name
      t.decimal :latitude
      t.decimal :longitude
      t.references :location, null: true, foreign_key: true

      t.timestamps
    end
  end
end
