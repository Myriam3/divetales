def create_trips(user, countries)
  trips = {}

  # Trip 1 Komodo
  komodo = Trip.find_or_create_by!(
    title: "Komodo Diving Trip 2025"
  ) do |trip|
    trip.user = user
    trip.start_date = Date.new(2025, 7, 10)
    trip.end_date = Date.new(2025, 7, 16)
    trip.info = "Komodo National Park, Indonesia 2025"
  end

  komodo.countries << countries["id"]

  trips["komodo_1"] = komodo

  # Trip 2 Mikomoto
  mikomoto = Trip.find_or_create_by!(
    title: "Mikomoto Diving Trip"
  ) do |trip|
    trip.user = user
    trip.start_date = Date.new(2025, 9, 20)
    trip.end_date = Date.new(2025, 9, 21)
    trip.info = "A short diving trip to explore the strong currents and pelagic life around Mikomoto."
  end

  mikomoto.countries << countries["jp"]

  trips["mikomoto_1"] = mikomoto

  # Trip 3 Indonesia & Malaysia
  indonesia_malaysia = Trip.find_or_create_by!(
    title: "Indonesia & Malaysia travel 2026"
  ) do |trip|
    trip.user = user
    trip.start_date = Date.new(2026, 8, 19)
    trip.end_date = Date.new(2026, 9, 04)
    trip.info = "Traveling to Tioman, Nusa Penida and Komodo National Park!"
  end

  indonesia_malaysia.countries << countries["id"]
  indonesia_malaysia.countries << countries["my"]

  trips["indonesia_malaysia"] = indonesia_malaysia

  # Trip 4 Bali
  bali_2025 = Trip.find_or_create_by!(
    title: "Bali 2025"
  ) do |trip|
    trip.user = user
    trip.start_date = Date.new(2025, 7, 10)
    trip.end_date = Date.new(2025, 7, 16)
    trip.info = ""
  end

  bali_2025.countries << countries["id"]
  trips["bali_2025"] = bali_2025

  return trips
end
