def create_locations(countries)
  {
    # ----- Japan -----
    "mikomoto" => Location.find_or_create_by!(name: "Izu Peninsula - Mikomoto Island", country: countries["jp"]),
    "kumomi" => Location.find_or_create_by!(name: "Izu Peninsula - Kumomi", country: countries["jp"]),
    "osezaki" => Location.find_or_create_by!(name: "Izu Peninsula - Osezaki", country: countries["jp"]),
    "futo" => Location.find_or_create_by!(name: "Izu Peninsula - Futo", country: countries["jp"]),
    "ito" => Location.find_or_create_by!(name: "Izu Peninsula - Ito", country: countries["jp"]),
    "atami" => Location.find_or_create_by!(name: "Izu Peninsula - Atami", country: countries["jp"]),
    "okinawa_main" => Location.find_or_create_by!(name: "Okinawa - Main Island", country: countries["jp"]),
    "ishigaki" => Location.find_or_create_by!(name: "Okinawa - Ishigaki", country: countries["jp"]),
    "miyakojima" => Location.find_or_create_by!(name: "Okinawa - Miyakojima", country: countries["jp"]),
    "yonaguni" => Location.find_or_create_by!(name: "Okinawa - Yonaguni", country: countries["jp"]),
    "ogasawara" => Location.find_or_create_by!(name: "Ogasawara Islands", country: countries["jp"]),
    "kashiwajima" => Location.find_or_create_by!(name: "Shikoku - Kashiwajima", country: countries["jp"]),

    # ----- Indonesia -----
    "gili" => Location.find_or_create_by!(name: "Gili Islands", country: countries["id"]),
    "nusa_penida" => Location.find_or_create_by!(name: "Bali - Nusa Penida", country: countries["id"]),
    "buleleng" => Location.find_or_create_by!(name: "Bali - Buleleng", country: countries["id"]),
    "tulamben" => Location.find_or_create_by!(name: "Bali - Tulamben (USAT Liberty)", country: countries["id"]),
    "komodo" => Location.find_or_create_by!(name: "Komodo National Park", country: countries["id"]),
    "raja_ampat" => Location.find_or_create_by!(name: "Raja Ampat", country: countries["id"]),
    "lembeh" => Location.find_or_create_by!(name: "Lembeh Strait", country: countries["id"]),
    "bunaken" => Location.find_or_create_by!(name: "Bunaken National Park", country: countries["id"]),
    "wakatobi" => Location.find_or_create_by!(name: "Wakatobi", country: countries["id"]),
    "banda_sea" => Location.find_or_create_by!(name: "Banda Sea", country: countries["id"]),
    "alor" => Location.find_or_create_by!(name: "Alor Archipelago", country: countries["id"]),
    "ambon" => Location.find_or_create_by!(name: "Ambon", country: countries["id"]),
    "derawan" => Location.find_or_create_by!(name: "Derawan Islands", country: countries["id"]),
    "pulau_weh" => Location.find_or_create_by!(name: "Pulau Weh", country: countries["id"]),

    # ----- Philippines -----
    "palawan" => Location.find_or_create_by!(name: "Palawan", country: countries["ph"]),
    "coron" => Location.find_or_create_by!(name: "Coron (Wrecks)", country: countries["ph"]),
    "cebu_moalboal" => Location.find_or_create_by!(name: "Cebu - Moalboal", country: countries["ph"]),
    "cebu_malapascua" => Location.find_or_create_by!(name: "Cebu - Malapascua", country: countries["ph"]),
    "bohol" => Location.find_or_create_by!(name: "Bohol - Panglao", country: countries["ph"]),
    "anilao" => Location.find_or_create_by!(name: "Batangas - Anilao", country: countries["ph"]),
    "tubbataha" => Location.find_or_create_by!(name: "Tubbataha Reefs", country: countries["ph"]),
    "apo_island" => Location.find_or_create_by!(name: "Negros - Apo Island", country: countries["ph"]),

    # ----- Thailand -----
    "similan" => Location.find_or_create_by!(name: "Similan Islands", country: countries["th"]),
    "surin" => Location.find_or_create_by!(name: "Surin Islands (Richelieu Rock)", country: countries["th"]),
    "koh_tao" => Location.find_or_create_by!(name: "Koh Tao", country: countries["th"]),
    "phuket" => Location.find_or_create_by!(name: "Phuket", country: countries["th"]),
    "koh_lanta" => Location.find_or_create_by!(name: "Koh Lanta", country: countries["th"]),

    # ----- Malaysia -----
    "sipadan" => Location.find_or_create_by!(name: "Sipadan", country: countries["my"]),
    "mabul" => Location.find_or_create_by!(name: "Mabul & Kapalai", country: countries["my"]),
    "tioman" => Location.find_or_create_by!(name: "Tioman Island", country: countries["my"]),
    "perhentian" => Location.find_or_create_by!(name: "Perhentian Islands", country: countries["my"]),

    # ----- Maldives -----
    "ari_atoll" => Location.find_or_create_by!(name: "Ari Atoll", country: countries["mv"]),
    "male_atoll" => Location.find_or_create_by!(name: "Male Atoll", country: countries["mv"]),
    "baa_atoll" => Location.find_or_create_by!(name: "Baa Atoll", country: countries["mv"]),
    "fuvahmulah" => Location.find_or_create_by!(name: "Fuvahmulah", country: countries["mv"]),

    # ----- Egypt (Red Sea) -----
    "sharm_el_sheikh" => Location.find_or_create_by!(name: "Sharm El-Sheikh", country: countries["eg"]),
    "dahab" => Location.find_or_create_by!(name: "Dahab", country: countries["eg"]),
    "hurghada" => Location.find_or_create_by!(name: "Hurghada", country: countries["eg"]),
    "marsa_alam" => Location.find_or_create_by!(name: "Marsa Alam", country: countries["eg"]),
    "brothers" => Location.find_or_create_by!(name: "Brother Islands", country: countries["eg"]),

    # ----- Mexico -----
    "cozumel" => Location.find_or_create_by!(name: "Cozumel", country: countries["mx"]),
    "cenotes" => Location.find_or_create_by!(name: "Playa del Carmen - Cenotes", country: countries["mx"]),
    "isla_mujeres" => Location.find_or_create_by!(name: "Isla Mujeres", country: countries["mx"]),
    "socorro" => Location.find_or_create_by!(name: "Socorro Islands (Revillagigedo)", country: countries["mx"]),
    "cabo_pulmo" => Location.find_or_create_by!(name: "Cabo Pulmo", country: countries["mx"]),
    "la_paz" => Location.find_or_create_by!(name: "La Paz", country: countries["mx"]),

    # ----- USA -----
    "florida_keys" => Location.find_or_create_by!(name: "Florida Keys", country: countries["us"]),
    "hawaii_kona" => Location.find_or_create_by!(name: "Hawaii - Kona (Manta Ray Night Dive)", country: countries["us"]),
    "hawaii_oahu" => Location.find_or_create_by!(name: "Hawaii - Oahu", country: countries["us"]),
    "monterey_bay" => Location.find_or_create_by!(name: "California - Monterey Bay", country: countries["us"]),
    "catalina" => Location.find_or_create_by!(name: "California - Catalina Island", country: countries["us"]),
    "morehead_city" => Location.find_or_create_by!(name: "North Carolina - Morehead City", country: countries["us"]),

    # ----- Australia -----
    "great_barrier_reef" => Location.find_or_create_by!(name: "Great Barrier Reef", country: countries["au"]),
    "ningaloo" => Location.find_or_create_by!(name: "Ningaloo Reef", country: countries["au"]),
    "yongala" => Location.find_or_create_by!(name: "SS Yongala Wreck", country: countries["au"]),
    "rowley_shoals" => Location.find_or_create_by!(name: "Rowley Shoals", country: countries["au"]),

    # ----- Central America & Caribbean -----
    "blue_hole" => Location.find_or_create_by!(name: "Belize - Great Blue Hole", country: countries["bz"]),
    "turneffe" => Location.find_or_create_by!(name: "Belize - Turneffe Atoll", country: countries["bz"]),
    "roatan" => Location.find_or_create_by!(name: "Honduras - Roatan", country: countries["hn"]),
    "utila" => Location.find_or_create_by!(name: "Honduras - Utila", country: countries["hn"]),
    "cocos" => Location.find_or_create_by!(name: "Costa Rica - Cocos Island", country: countries["cr"]),
    "tiger_beach" => Location.find_or_create_by!(name: "Bahamas - Tiger Beach", country: countries["bs"]),
    "bimini" => Location.find_or_create_by!(name: "Bahamas - Bimini", country: countries["bs"]),
    "grand_cayman" => Location.find_or_create_by!(name: "Cayman Islands - Grand Cayman", country: countries["ky"]),
    "little_cayman" => Location.find_or_create_by!(name: "Cayman Islands - Little Cayman (Bloody Bay Wall)", country: countries["ky"]),
    "bonaire_marine_park" => Location.find_or_create_by!(name: "Bonaire National Marine Park", country: countries["bq"]),
    "curacao" => Location.find_or_create_by!(name: "Curacao", country: countries["cw"]),
    "jardines_reina" => Location.find_or_create_by!(name: "Cuba - Jardines de la Reina", country: countries["cu"]),

    # ----- South America -----
    "galapagos" => Location.find_or_create_by!(name: "Ecuador - Galapagos Islands", country: countries["ec"]),
    "malpelo" => Location.find_or_create_by!(name: "Colombia - Malpelo Island", country: countries["co"]),

    # ----- Oceania / Pacific -----
    "palau_koror" => Location.find_or_create_by!(name: "Palau - Koror", country: countries["pw"]),
    "fiji_taveuni" => Location.find_or_create_by!(name: "Fiji - Taveuni", country: countries["fj"]),
    "fiji_bligh" => Location.find_or_create_by!(name: "Fiji - Bligh Water", country: countries["fj"]),
    "rangiroa" => Location.find_or_create_by!(name: "French Polynesia - Rangiroa", country: countries["pf"]),
    "fakarava" => Location.find_or_create_by!(name: "French Polynesia - Fakarava", country: countries["pf"]),
    "moorea" => Location.find_or_create_by!(name: "French Polynesia - Moorea", country: countries["pf"]),
    "truk_lagoon" => Location.find_or_create_by!(name: "Micronesia - Chuuk (Truk) Lagoon", country: countries["fm"]),
    "yap" => Location.find_or_create_by!(name: "Micronesia - Yap", country: countries["fm"]),

    # ----- Africa & Indian Ocean -----
    "aliwal_shoal" => Location.find_or_create_by!(name: "South Africa - Aliwal Shoal", country: countries["za"]),
    "false_bay" => Location.find_or_create_by!(name: "South Africa - False Bay", country: countries["za"]),
    "zanzibar" => Location.find_or_create_by!(name: "Tanzania - Zanzibar", country: countries["tz"]),
    "mafia_island" => Location.find_or_create_by!(name: "Tanzania - Mafia Island", country: countries["tz"]),
    "tofo" => Location.find_or_create_by!(name: "Mozambique - Praia do Tofo", country: countries["mz"]),
    "daymaniyat" => Location.find_or_create_by!(name: "Oman - Daymaniyat Islands", country: countries["om"]),

    # ----- Europe -----
    "scapa_flow" => Location.find_or_create_by!(name: "UK - Scapa Flow", country: countries["gb"]),
    "gozo" => Location.find_or_create_by!(name: "Malta - Gozo", country: countries["mt"])
  }
end
