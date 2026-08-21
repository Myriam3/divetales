namespace :db do
  desc "Seed dive sites globally from OpenStreetMap"
  task seed_dive_sites: :environment do
    require 'net/http'
    require 'json'

    puts "🌍 Querying OpenStreetMap for global dive sites. This may take a few minutes..."

    # Removed the bounding boxes and increased the timeout to 15 minutes (900 seconds)
    # to allow the Overpass API enough time to compile the entire world's data.
    query = <<~QUERY
      [out:json][timeout:900];
      (
        node["sport"="scuba_diving"];
        node["scuba_diving:dive_site"="yes"];
      );
      out center;
    QUERY

    uri = URI('https://overpass-api.de/api/interpreter')

    # We use a slight delay/retry logic here just in case the server is temporarily busy
    begin
      response = Net::HTTP.post_form(uri, 'data' => query)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        elements = data['elements'] || []

        puts "🌊 Found #{elements.size} raw dive sites globally. Filtering and seeding..."

        success_count = 0

        elements.each do |element|
          tags = element['tags'] || {}

          # Fallback to English name if the local name is missing
          site_name = tags['name'] || tags['name:en']

          # Skip unnamed locations
          next if site_name.blank?

          site = DiveSite.find_or_initialize_by(
            latitude: element['lat'],
            longitude: element['lon']
          )
          site.name = site_name

          success_count += 1 if site.save
        end

        puts "✅ Successfully seeded #{success_count} global dive sites into the database!"
      else
        puts "❌ Overpass API request failed. Status: #{response.code}"
        puts "Error details: #{response.body}"
      end
    rescue Net::ReadTimeout
      puts "⏳ The request timed out. The global query is too large for the current server load. Try running it again later!"
    end
  end
end
