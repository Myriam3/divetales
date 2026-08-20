require "json"

def load_countries
  country_data = JSON.parse(
    File.read(Rails.root.join("db", "seeds", "countries.json"))
  )

  country_data.each_with_object({}) do |country_data, countries|
    country = Country.find_or_create_by!(
      code: country_data["code"]
    ) do |item|
      item.name = country_data["name"]
    end

    countries[country.code] = country
  end
end
