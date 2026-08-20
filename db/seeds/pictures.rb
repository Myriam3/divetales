require "json"

def create_pictures_species(dives)
  puts "Creating pictures (can take few minutes)"

  pictures = []
  pictures_json = JSON.parse(
    File.read(Rails.root.join("db/seeds/pictures.json"))
  )

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

  pictures_json.each do |data|
    picture = create_picture(
      dive: dives[data["dive_key"].first],
      date_time: data["date_time"],
      species: data["species"].map { |species| getSpecies(species) },
      image_path: data["image_path"]
    )

    pictures << picture
  end


  puts "#{pictures.length} pictures created!"
end
