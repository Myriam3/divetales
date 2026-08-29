require "json"

def create_dives(trips, locations)
  dives_json = JSON.parse(
    File.read(Rails.root.join("db/seeds/dives.json"))
  )

  dives_json.each_with_object({}) do |data, dives|
    attributes = {
      trip: trips[data["trip_key"]],
      date: Date.parse(data["date"]),
      dive_number: data["dive_number"],
      dive_site_name: data["dive_site_name"]
    }

    dive = Dive.find_or_create_by!(attributes) do |new_dive|
      new_dive.location = locations[data["location_key"]]
      new_dive.latitude = data["latitude"]
      new_dive.longitude = data["longitude"]
      new_dive.dive_types = data["dive_types"]
      new_dive.duration = data["duration"]
      new_dive.max_depth = data["max_depth"]
      new_dive.avg_depth = data["avg_depth"]
      new_dive.max_temp = data["max_temp"]
      new_dive.min_temp = data["min_temp"]
      new_dive.avg_temp = data["avg_temp"]
      new_dive.start_time = data["start_time"]
      new_dive.end_time = data["end_time"]
      new_dive.note = data["note"]
      new_dive.depth_over_time = data["depth_over_time"].present? ? JSON.generate(data["depth_over_time"]) : nil
      new_dive.tank_type = data["tank_type"] || 1
      new_dive.gauge_pressure_start = data["gauge_pressure_start"]
      new_dive.gauge_pressure_end = data["gauge_pressure_end"]
      new_dive.dive_number = data["dive_number"]
    end

    existing += 1 unless dive.previous_changes.key?("id")
    dives[data["key"]] = dive
  end
end
