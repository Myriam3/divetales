class ChangeTypeToDiveTypes < ActiveRecord::Migration[8.1]
  def change
    remove_column :dives, :type, :integer, array: true, default: []
    add_column :dives, :dive_types, :string, array: true, default: []
  end
end
