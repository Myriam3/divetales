def create_trips(user, countries)
  trips = {}

  # Trip 1 Komodo
  komodo = Trip.find_or_create_by!(
    title: "Komodo Diving Trip 2026"
  ) do |trip|
    trip.user = user
    trip.start_date = Date.new(2026, 7, 10)
    trip.end_date = Date.new(2026, 7, 16)
    trip.info = "Komodo National Park, Indonesia 2026"
  end

  komodo.countries << countries["id"]

  trips["komodo_1"] = komodo

  # Trip 2 Mikomoto
  mikomoto = Trip.find_or_create_by!(
    title: "Mikomoto Diving Trip"
  ) do |trip|
    trip.user = user
    trip.start_date = Date.new(2026, 9, 20)
    trip.end_date = Date.new(2026, 9, 21)
    trip.info = "A short diving trip to explore the strong currents and pelagic life around Mikomoto."
  end

  mikomoto.countries << countries["jp"]

  trips["mikomoto_1"] = mikomoto

  # Trip 3 Indonesia & Malaysia
  indonesia_malaysia = Trip.find_or_create_by!(
    title: "Indonesia & Malaysia travel 2025"
  ) do |trip|
    trip.user = user
    trip.start_date = Date.new(2026, 07, 01)
    trip.end_date = Date.new(2026, 07, 31)
    trip.info = "1 month traveling to Bali, Mabul, Sipadan, North Sulawesi and Raja Ampat"
  end

  indonesia_malaysia.countries << countries["id"]
  indonesia_malaysia.countries << countries["my"]

  trips["indonesia_malaysia"] = indonesia_malaysia

  return trips
end
