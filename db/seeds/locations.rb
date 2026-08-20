def create_locations(countries)
{
  "mikomoto" => Location.find_or_create_by!(
    name: "Izu Peninsula - Mikomoto Island",
    country: countries["jp"]
  ),
  "kumomi" => Location.find_or_create_by!(
    name: "Izu Peninsula - Kumomi",
    country: countries["jp"]
  ),
  "gili" => Location.find_or_create_by!(
    name: "Gili Island",
    country: countries["id"]
  ),
  "nusa_penida" => Location.find_or_create_by!(
    name: "Bali - Nusa Penida",
    country: countries["id"]
  ),
  "buleleng" => Location.find_or_create_by!(
    name: "Bali - Buleleng",
    country: countries["id"]
  ),
  "komodo" => Location.find_or_create_by!(
    name: "Komodo",
    country: countries["id"]
  )
}
end
