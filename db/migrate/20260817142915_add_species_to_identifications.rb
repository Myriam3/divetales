class AddSpeciesToIdentifications < ActiveRecord::Migration[8.1]
  def change
    add_reference :identifications, :species, null: true, foreign_key: true
  end
end
