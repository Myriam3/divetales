class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description, limit: 500
      t.integer :classification, default: 0 # 0 -> other
      t.string :icon_url

      t.timestamps
    end
  end
end
