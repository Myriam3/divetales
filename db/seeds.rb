# This file should ensure the existence of records required to run the application
# in every environment (production, development, test).
#
# The code here should be idempotent so that it can be executed at any point
# in every environment.
#
# The data can then be loaded with the bin/rails db:seed command
# (or created alongside the database with db:setup).

# ==========================================
# Clean database
# ==========================================

# comment/uncomment if needed
# User.destroy_all
Identification.destroy_all
Dive.destroy_all
TripCountry.destroy_all
Trip.destroy_all

Picture.destroy_all

DiveSite.destroy_all
Location.destroy_all
Country.destroy_all

Species.destroy_all
Category.destroy_all

# ==========================================
# User
# ==========================================

user = User.find_or_create_by!(
  email: "demo@example.com"
) do |user|
  user.name = "Demo Diver"
  user.password = "test123"
  user.admin = true
end

# ==========================================
# Categories
# ==========================================

categories = {
  fish: [
    "Sharks",
    "Rays",
    "Eels",
    "Seahorses & Pipefish",
    "Gobies & Blennies",
    "Groupers",
    "Wrasses",
    "Lionfish, Scorpionfish & Stonefish",
    "Triggerfish & Filefish",
    "Pufferfish & Porcupinefish",
    "Damselfish & Anemonefish",
    "Parrotfish",
    "Angelfish & Butterflyfish",
    "Pelagic Fish",
    "Catfish",
    "Boxfish & Cowfish",
    "Frogfish & Anglerfish",
    "Other Fish"
  ],

  mammal: [
    "Whales",
    "Dolphins & Orcas",
    "Seals & Sea Lions",
    "Sea Otters",
    "Manatees & Dugongs"
  ],

  reptile: [
    "Sea Turtles",
    "Sea Snakes",
    "Marine Iguanas"
  ],

  crustacean: [
    "Shrimps",
    "Mantis Shrimps",
    "Crabs",
    "Lobsters",
    "Other Crustaceans"
  ],

  mollusk: [
    "Nudibranchs",
    "Sea Hares",
    "Sea Snails",
    "Octopuses",
    "Squids",
    "Cuttlefish",
    "Clams",
    "Other Mollusks"
  ],

  cnidarian: [
    "Jellyfish",
    "Corals",
    "Sea Anemones",
    "Siphonophores",
    "Hydroids",
    "Sea Pens"
  ],

  echinoderm: [
    "Stars",
    "Sea Urchins",
    "Sea Cucumbers",
    "Crinoids"
  ],

  annelid: [
    "Bristle Worms",
    "Tubeworms",
    "Other Annelids"
  ],

  sponge: [
    "Tube Sponges",
    "Barrel Sponges",
    "Encrusting Sponges"
  ]
}

categories.each do |classification, category_names|
  category_names.each do |name|
    Category.find_or_create_by!(
      name: name,
      classification: classification
    )
  end
end

# ==========================================
# Species
# ==========================================
require_relative "seeds/species"
species = species_list

species.each do |data|
  category = Category.find_by!(name: data[:category])

  Species.find_or_create_by!(
    scientific_name: data[:scientific_name]
  ) do |species|
    species.name = data[:name]
    species.category = category
    species.tags = data[:tags]
    species.description = data[:description]
    species.wiki_link = data[:wiki_link]
  end
end

# ==========================================
# Countries
# ==========================================

require_relative "seeds/countries"
countries = load_countries
puts "#{countries.length} countries created"

# ==========================================
# Locations
# ==========================================

require_relative "seeds/locations"

locations = create_locations(countries)
puts "#{locations.length} locations created"

# ==========================================
# Dive sites
# ==========================================

require_relative "seeds/dive_sites"

dive_sites = load_dive_sites(locations)
puts "#{dive_sites.length} dive sites created"


# ==========================================
# Trips
# ==========================================

require_relative "seeds/trips"

trips = create_trips(user, countries)
puts "#{trips.length} trips created"

# ==========================================
# Dives
# ==========================================

require_relative "seeds/dives"
dives = create_dives(trips, locations)
puts "#{dives.length} dives created"

# ==========================================
# Pictures
# ==========================================
require_relative "seeds/pictures"
create_pictures_species(dives)

# ==========================================
puts "seed finished"
