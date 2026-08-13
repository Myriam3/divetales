class CreatePictureSpecies < ActiveRecord::Migration[8.1]
  def change
    create_table :picture_species do |t|
      t.references :picture, null: false, foreign_key: true
      t.references :species, null: false, foreign_key: true

      t.timestamps
    end
  end
end
