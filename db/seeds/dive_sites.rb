require "json"

def load_dive_sites
  site_data = JSON.parse(
    File.read(Rails.root.join("db", "seeds", "dive_sites.json"))
  )

  site_data.each do |data|
    location = Location.find_by(name: data["location_name"])

    if location.nil?
      puts "⚠️ Warning: Could not find location '#{data["location_name"]}' for dive site '#{data["name"]}'. Skipping."
      next
    end

    DiveSite.find_or_create_by!(name: data["name"], location_id: location.id) do |site|
      site.latitude = data["latitude"]
      site.longitude = data["longitude"]
    end
  end
end
