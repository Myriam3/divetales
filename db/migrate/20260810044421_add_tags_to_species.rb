class AddTagsToSpecies < ActiveRecord::Migration[8.1]
  def change
    add_column :species, :tags, :string, array: true, default: []
  end
end
