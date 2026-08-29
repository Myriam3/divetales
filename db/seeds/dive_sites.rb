require "json"

def load_dive_sites(locations)
  dive_sites_json = JSON.parse(
    File.read(Rails.root.join("db", "seeds", "dive_sites.json"))
  )

  dive_sites_json.each do |data|
    location = locations[data["location_key"]]

    if location.nil?
      puts "⚠️ Warning: Could not find location key '#{data["location_key"]}' for dive site '#{data["name"]}'. Skipping."
      next
    end

    DiveSite.find_or_create_by!(
      name: data["name"],
      location: location
    ) do |dive_site|
      dive_site.latitude = data["latitude"]
      dive_site.longitude = data["longitude"]
    end
  end
end
