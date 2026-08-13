class CreateSpecies < ActiveRecord::Migration[8.1]
  def change
    create_table :species do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false, limit: 150
      t.text :description, limit: 500
      t.string :scientific_name, limit: 150
      t.string :wiki_link
      t.string :default_img

      t.timestamps
    end
  end
end
