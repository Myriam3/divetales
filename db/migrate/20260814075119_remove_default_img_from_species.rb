class RemoveDefaultImgFromSpecies < ActiveRecord::Migration[8.1]
  def change
    remove_column :species, :default_img, :string
  end
end
