class AddUniqueIndexToPictureSpecies < ActiveRecord::Migration[8.1]
  def change
    add_index :picture_species, [:picture_id, :species_id], unique: true
  end
end
