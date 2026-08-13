class CreatePictures < ActiveRecord::Migration[8.1]
  def change
    create_table :pictures do |t|
      t.references :dive, null: false, foreign_key: true
      t.datetime :date_time

      t.timestamps
    end
  end
end
