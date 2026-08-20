class AddDetailsToSpecies < ActiveRecord::Migration[8.1]
  def change
    add_column :species, :details, :jsonb
  end
end
