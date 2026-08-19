class AddTimesTanKPressureToDives < ActiveRecord::Migration[8.1]
  def change
    add_column :dives, :start_time, :datetime
    add_column :dives, :end_time, :datetime
    add_column :dives, :tank_type, :integer, default: 1, null: false
    add_column :dives, :gauge_pressure_start, :float
    add_column :dives, :gauge_pressure_end, :float
  end
end
