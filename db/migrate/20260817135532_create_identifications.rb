class CreateIdentifications < ActiveRecord::Migration[8.1]
  def change
    create_table :identifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :dive, null: true, foreign_key: true
      t.text :user_prompt
      t.jsonb :results
      t.string :status

      t.timestamps
    end
  end
end
