class AddFormInputsToIdentifications < ActiveRecord::Migration[8.1]
  def change
    add_column :identifications, :form_inputs, :jsonb
  end
end
