def create_pictures_species(dives)
  puts "Creating pictures (can take few minutes)"

  def getSpecies(sci_name)
      Species.find_by!(
      scientific_name: sci_name
    )
  end

  # JPEG only
  def create_picture(dive:, date_time:, image_path: nil, species: nil)
    picture = Picture.find_or_create_by!(
      dive: dive,
      date_time: date_time
    )

    if image_path.present? && !picture.photo.attached?
      file_path = Rails.root.join("db", "seed_images", "#{image_path}.jpg")

      picture.photo.attach(
        io: File.open(file_path),
        filename: File.basename(file_path),
        content_type: "image/jpeg"
      )
    end

    Array(species).each do |species|
      picture.species << species unless picture.species.include?(species)
    end

    puts "#{image_path} picture created"

    picture
  end

  # Komodo pictures
  create_picture(
    dive: dives["manta_point"],
    date_time: "2026-07-11 09:30",
    species: getSpecies("Mobula birostris"),
    image_path: "dummy-manta"
  )

  create_picture(
    dive: dives["manta_point"],
    date_time: "2026-07-11 09:42",
    species: [getSpecies("Mobula birostris"), getSpecies("Mola mola")],
    image_path: "dummy-manta-molamola"
  )

  create_picture(
    dive: dives["manta_point"],
    date_time: "2026-07-11 09:55",
    image_path: "dummy-reef"
  )

  create_picture(
    dive: dives["batu_bolong"],
    date_time: "2026-07-11 14:15",
    species: getSpecies("Amphiprion ocellaris"),
    image_path: "dummy-nemo"
  )

  create_picture(
    dive: dives["crystal_rock"],
    date_time: "2026-07-13 10:30",
    species: getSpecies("Amphiprion ocellaris"),
    image_path: "dummy-nemo-02"
  )

  create_picture(
    dive: dives["crystal_rock"],
    date_time: "2026-07-13 10:05",
    species: getSpecies("Triaenodon obesus"),
    image_path: "dummy-whitetip-reef-shark"
  )

  create_picture(
    dive: dives["batu_bolong"],
    date_time: "2026-07-11 14:30",
    image_path: "dummy-reef-02"
  )

  create_picture(
    dive: dives["batu_bolong"],
    date_time: "2026-07-12 09:25",
    species: getSpecies("Chelonia mydas"),
    image_path: "dummy-green-turtle"
  )

  create_picture(
    dive: dives["manta_point_night"],
    date_time: "2026-07-15 20:10",
    species: getSpecies("Octopus vulgaris"),
    image_path: "dummy-octopus-night"
  )

  create_picture(
    dive: dives["siaba_besar"],
    date_time: "2026-07-14 09:35",
    species: getSpecies("Thecacera pacifica"),
    image_path: "dummy-pikachu-nudi"
  )

  create_picture(
    dive: dives["siaba_besar"],
    date_time: "2026-07-14 09:55",
    species: getSpecies("Jorunna funebris"),
    image_path: "dummy-oreo-nudi"
  )

  create_picture(
    dive: dives["siaba_besar"],
    date_time: "2026-07-14 09:40",
    image_path: "dummy-boxfish"
  )

  create_picture(
    dive: dives["siaba_besar"],
    date_time: "2026-07-14 10:05",
    species: getSpecies("Odontodactylus scyllarus"),
    image_path: "dummy-mantis"
  )

  # Mikomoto pictures

  create_picture(
    dive: dives["mikomoto_main_rock"],
    date_time: "2026-08-11 07:45",
    species: getSpecies("Sphyrna lewini"),
    image_path: "dummy-hammerhead"
  )

  puts "Done!"
end
