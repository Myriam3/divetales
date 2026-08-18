class RemoveDefaultImgFromSpecies < ActiveRecord::Migration[8.1]
  def change
    remove_column :species, :default_img, :string, if_exists: true
  end
end
