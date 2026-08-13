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

Dive.destroy_all
TripCountry.destroy_all
Trip.destroy_all

Species.destroy_all
Category.destroy_all

Location.destroy_all
Country.destroy_all

User.destroy_all


# ==========================================
# User
# ==========================================

user = User.find_or_create_by!(
  email: "demo@example.com"
) do |user|
  user.name = "Demo Diver"
  user.password = "test123"
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
    "Lionfish & Scorpionfish",
    "Triggerfish & Filefish",
    "Pufferfish & Porcupinefish",
    "Damselfish & Anemonefish",
    "Parrotfish",
    "Angelfish & Butterflyfish",
    "Pelagic Fish",
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

species = [
  # ----------------------------------------
  # Fish
  # ----------------------------------------

  {
    name: "Oceanic Whitetip Shark",
    scientific_name: "Carcharhinus longimanus",
    category: "Sharks",
    tags: ["tropical", "pelagic"],
    description: "A large pelagic shark found mainly in tropical and warm temperate open oceans.",
    wiki_link: "https://en.wikipedia.org/wiki/Oceanic_whitetip_shark"
  },

  {
    name: "Whitetip Reef Shark",
    scientific_name: "Triaenodon obesus",
    category: "Sharks",
    tags: ["tropical", "reef", "nocturnal"],
    description: "A reef-associated shark commonly found resting in caves and under reef ledges.",
    wiki_link: "https://en.wikipedia.org/wiki/Whitetip_reef_shark"
  },

  {
    name: "Clownfish",
    scientific_name: "Amphiprion ocellaris",
    category: "Damselfish & Anemonefish",
    tags: ["tropical", "reef"],
    description: "A small reef fish that lives in close association with sea anemones.",
    wiki_link: "https://en.wikipedia.org/wiki/Amphiprion_ocellaris"
  },

  {
    name: "Green Moray",
    scientific_name: "Gymnothorax funebris",
    category: "Eels",
    tags: ["tropical", "reef", "nocturnal"],
    description: "A large moray eel found around rocky reefs and coastal waters of the tropical Atlantic.",
    wiki_link: "https://en.wikipedia.org/wiki/Green_moray"
  },

  {
    name: "Moorish Idol",
    scientific_name: "Zanclus cornutus",
    category: "Angelfish & Butterflyfish",
    tags: ["tropical", "reef"],
    description: "A distinctive reef fish recognized by its long dorsal fin and bold black, white, and yellow pattern.",
    wiki_link: "https://en.wikipedia.org/wiki/Moorish_idol"
  },

  {
    name: "Ocean Sunfish",
    scientific_name: "Mola mola",
    category: "Pelagic Fish",
    tags: ["pelagic"],
    description: "A massive oceanic fish known for its unusual flattened body and large size.",
    wiki_link: "https://en.wikipedia.org/wiki/Ocean_sunfish"
  },

  {
    name: "Giant Oceanic Manta Ray",
    scientific_name: "Mobula birostris",
    category: "Rays",
    tags: ["tropical", "pelagic"],
    description: "The largest ray species, commonly found in tropical and subtropical oceanic waters.",
    wiki_link: "https://en.wikipedia.org/wiki/Giant_oceanic_manta_ray"
  },

  {
    name: "Great Barracuda",
    scientific_name: "Sphyraena barracuda",
    category: "Pelagic Fish",
    tags: ["tropical", "pelagic", "reef"],
    description: "A large predatory fish found in tropical and subtropical coastal and open waters.",
    wiki_link: "https://en.wikipedia.org/wiki/Great_barracuda"
  },


  # ----------------------------------------
  # Reptiles
  # ----------------------------------------

  {
    name: "Green Sea Turtle",
    scientific_name: "Chelonia mydas",
    category: "Sea Turtles",
    tags: ["tropical", "reef", "seagrass"],
    description: "A widely distributed sea turtle commonly found around reefs, shallow coastal waters, and seagrass meadows.",
    wiki_link: "https://en.wikipedia.org/wiki/Green_sea_turtle"
  },


  # ----------------------------------------
  # Crustaceans
  # ----------------------------------------

  {
    name: "Peacock Mantis Shrimp",
    scientific_name: "Odontodactylus scyllarus",
    category: "Mantis Shrimps",
    tags: ["tropical", "reef", "macro"],
    description: "A brightly colored mantis shrimp known for its powerful striking appendages.",
    wiki_link: "https://en.wikipedia.org/wiki/Odontodactylus_scyllarus"
  },


  # ----------------------------------------
  # Mollusks
  # ----------------------------------------

  {
    name: "Blue Dragon",
    scientific_name: "Glaucus atlanticus",
    category: "Nudibranchs",
    tags: ["pelagic", "macro"],
    description: "A small pelagic nudibranch known for its blue coloration and floating lifestyle.",
    wiki_link: "https://en.wikipedia.org/wiki/Glaucus_atlanticus"
  },

  {
    name: "Common Octopus",
    scientific_name: "Octopus vulgaris",
    category: "Octopuses",
    tags: ["reef", "nocturnal"],
    description: "A widespread octopus commonly found on rocky reefs, coastal seabeds, and other sheltered habitats.",
    wiki_link: "https://en.wikipedia.org/wiki/Octopus_vulgaris"
  },

  {
    name: "Pikachu Nudibranch",
    scientific_name: "Thecacera pacifica",
    category: "Nudibranchs",
    tags: ["tropical", "reef", "macro"],
    description: "A small brightly colored nudibranch known for its yellow body and distinctive dark markings.",
    wiki_link: "https://en.wikipedia.org/wiki/Thecacera_pacifica"
  },


  # ----------------------------------------
  # Cnidarians
  # ----------------------------------------

  {
    name: "Moon Jellyfish",
    scientific_name: "Aurelia aurita",
    category: "Jellyfish",
    tags: ["pelagic"],
    description: "A translucent jellyfish recognized by its four characteristic horseshoe-shaped reproductive organs.",
    wiki_link: "https://en.wikipedia.org/wiki/Aurelia_aurita"
  },


  # ----------------------------------------
  # Echinoderms
  # ----------------------------------------

  {
    name: "Common Sea Star",
    scientific_name: "Asterias rubens",
    category: "Stars",
    tags: ["reef"],
    description: "A common sea star found on rocky and sandy seabeds in the North Atlantic.",
    wiki_link: "https://en.wikipedia.org/wiki/Asterias_rubens"
  },


  # ----------------------------------------
  # Annelids
  # ----------------------------------------

  {
    name: "Christmas Tree Worm",
    scientific_name: "Spirobranchus giganteus",
    category: "Tubeworms",
    tags: ["tropical", "reef", "macro"],
    description: "A colorful tube worm with two spiral crowns that commonly lives embedded in reef-building corals.",
    wiki_link: "https://en.wikipedia.org/wiki/Spirobranchus_giganteus"
  },


  # ----------------------------------------
  # Sponges
  # ----------------------------------------

  {
    name: "Yellow Tube Sponge",
    scientific_name: "Aplysina fistularis",
    category: "Tube Sponges",
    tags: ["tropical", "reef"],
    description: "A yellow tubular sponge commonly found attached to tropical rocky and coral reefs.",
    wiki_link: "https://en.wikipedia.org/wiki/Aplysina_fistularis"
  }
]

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

japan = Country.find_or_create_by!(
  name: "Japan",
  code: "jp"
)

indonesia = Country.find_or_create_by!(
  name: "Indonesia",
  code: "id"
)


# ==========================================
# Locations
# ==========================================

mikomoto = Location.find_or_create_by!(
  name: "Mikomoto Island",
  country: japan
)

komodo = Location.find_or_create_by!(
  name: "Komodo",
  country: indonesia
)


# ==========================================
# Trips
# ==========================================

komodo_trip = Trip.find_or_create_by!(
  title: "Komodo Diving Trip 2026"
) do |trip|
  trip.user = user
  trip.start_date = Date.new(2026, 7, 10)
  trip.end_date = Date.new(2026, 7, 16)
  trip.info = "Komodo National Park, Indonesia 2026"
end

komodo_trip.countries << indonesia unless komodo_trip.countries.include?(indonesia)


mikomoto_trip = Trip.find_or_create_by!(
  title: "Mikomoto Diving Trip"
) do |trip|
  trip.user = user
  trip.start_date = Date.new(2026, 9, 20)
  trip.end_date = Date.new(2026, 9, 21)
  trip.info = "A short diving trip to explore the strong currents and pelagic life around Mikomoto."
end

mikomoto_trip.countries << japan unless mikomoto_trip.countries.include?(japan)


# ==========================================
# Dives
# ==========================================

Dive.find_or_create_by!(
  trip: komodo_trip,
  date: Date.new(2026, 7, 11),
  dive_site_name: "Manta Point"
) do |dive|
  dive.latitude = -8.55047
  dive.longitude = 119.59923
  dive.location = komodo
  dive.dive_types = ["boat", "drift"]
  dive.duration = 52
  dive.max_depth = 18.0
  dive.avg_depth = 11.5
  dive.max_temp = 27.0
  dive.min_temp = 25.0
  dive.avg_temp = 26.0
  dive.note = "Strong current with several manta rays."
end


Dive.find_or_create_by!(
  trip: komodo_trip,
  date: Date.new(2026, 7, 11),
  dive_site_name: "Batu Bolong"
) do |dive|
  dive.latitude = -8.53608
  dive.longitude = 119.61399
  dive.location = komodo
  dive.dive_types = ["boat", "wall"]
  dive.duration = 48
  dive.max_depth = 25.0
  dive.avg_depth = 14.2
  dive.max_temp = 27.0
  dive.min_temp = 25.0
  dive.avg_temp = 26.0
  dive.note = "Colorful coral reef with abundant tropical fish."
end


Dive.find_or_create_by!(
  trip: komodo_trip,
  date: Date.new(2026, 7, 12),
  dive_site_name: "Castle Rock"
) do |dive|
  dive.latitude = -8.42890
  dive.longitude = 119.56284
  dive.location = komodo
  dive.dive_types = ["boat", "drift"]
  dive.duration = 50
  dive.max_depth = 26.0
  dive.avg_depth = 15.0
  dive.max_temp = 27.0
  dive.min_temp = 24.5
  dive.avg_temp = 25.5
  dive.note = "Excellent visibility and large schools of fish."
end


Dive.find_or_create_by!(
  trip: komodo_trip,
  date: Date.new(2026, 7, 13),
  dive_site_name: "Crystal Rock"
) do |dive|
  dive.latitude = -8.43903
  dive.longitude = 119.56660
  dive.location = komodo
  dive.dive_types = ["boat", "wall"]
  dive.duration = 46
  dive.max_depth = 23.0
  dive.avg_depth = 13.8
  dive.max_temp = 27.0
  dive.min_temp = 25.0
  dive.avg_temp = 26.0
  dive.note = "Beautiful reef with sharks, turtles and schools of fish."
end


Dive.find_or_create_by!(
  trip: komodo_trip,
  date: Date.new(2026, 7, 14),
  dive_site_name: "Siaba Besar"
) do |dive|
  dive.latitude = -8.54826
  dive.longitude = 119.64884
  dive.location = komodo
  dive.dive_types = ["boat", "drift"]
  dive.duration = 55
  dive.max_depth = 19.0
  dive.avg_depth = 10.8
  dive.max_temp = 28.0
  dive.min_temp = 26.0
  dive.avg_temp = 27.0
  dive.note = "Calm reef dive with turtles and macro life."
end


Dive.find_or_create_by!(
  trip: komodo_trip,
  date: Date.new(2026, 7, 15),
  dive_site_name: "Manta Point Night Dive"
) do |dive|
  dive.latitude = -8.55047
  dive.longitude = 119.59923
  dive.location = komodo
  dive.dive_types = ["boat", "night"]
  dive.duration = 47
  dive.max_depth = 17.0
  dive.avg_depth = 9.8
  dive.max_temp = 27.0
  dive.min_temp = 25.0
  dive.avg_temp = 26.0
  dive.note = "Night dive with nudibranchs, crabs and nocturnal reef life."
end


Dive.find_or_create_by!(
  trip: mikomoto_trip,
  date: Date.new(2026, 9, 20),
  dive_site_name: "Mikomoto Main Rock"
) do |dive|
  dive.latitude = 34.57604
  dive.longitude = 138.94140
  dive.location = mikomoto
  dive.dive_types = ["boat", "drift"]
  dive.duration = 42
  dive.max_depth = 28.0
  dive.avg_depth = 17.5
  dive.max_temp = 25.0
  dive.min_temp = 22.0
  dive.avg_temp = 23.5
  dive.note = "Strong current with large schools of pelagic fish and hammerhead sharks."
end


Dive.find_or_create_by!(
  trip: mikomoto_trip,
  date: Date.new(2026, 9, 20),
  dive_site_name: "Mikomoto South Point"
) do |dive|
  dive.latitude = 34.57604
  dive.longitude = 138.94140
  dive.location = mikomoto
  dive.dive_types = ["boat", "drift", "deep"]
  dive.duration = 39
  dive.max_depth = 32.0
  dive.avg_depth = 19.2
  dive.max_temp = 25.0
  dive.min_temp = 21.5
  dive.avg_temp = 23.0
  dive.note = "Deep drift dive with excellent visibility and pelagic life."
end
