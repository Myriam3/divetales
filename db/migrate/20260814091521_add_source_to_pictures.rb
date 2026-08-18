class AddSourceToPictures < ActiveRecord::Migration[8.1]
  def change
    add_column :pictures, :source, :integer
  end
end
