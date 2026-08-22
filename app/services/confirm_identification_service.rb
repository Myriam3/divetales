# app/services/confirm_identification_service.rb
require "open-uri"

class ConfirmIdentificationService
  def self.call(**args)
    new(**args).call
  end

  def initialize(user:, identification:, dive:, result:, common_name:, default_photo_url:)
    @user = user
    @identification = identification
    @dive = dive
    @result = result
    @scientific_name = result["scientific_name"].to_s.strip
    @common_name = common_name.presence || @scientific_name
    @default_photo_url = default_photo_url
  end

  def call
    ActiveRecord::Base.transaction do
      species = find_or_initialize_species
      attach_default_photo_to_species(species) if @default_photo_url.present? && !species.default_photo.attached?
      species.save!

      create_dive_picture(species)

      @identification.destroy!

      species
    end
  end

  private

  def find_or_initialize_species
    species = Species.find_or_initialize_by(scientific_name: @scientific_name)

    if species.new_record?
      species.name = @common_name
      species.category = find_category
      species.wiki_link = @result.dig("inaturalist", 0, "wikipedia_url")
    end

    species
  end

  def find_category
    marine_class = @result["marine_class"].to_s.strip
    classification = marine_class.downcase.singularize
    category_name = @result["category"].to_s.strip

    Category.find_by!(name: category_name, classification: classification)
  end

  def attach_default_photo_to_species(species)
    downloaded_image = URI.open(@default_photo_url)
    species.default_photo.attach(
      io: downloaded_image,
      filename: "#{@scientific_name.parameterize}-default.jpg",
      content_type: 'image/jpeg'
    )
  rescue StandardError => e
    Rails.logger.error "Failed to download reference image for #{@scientific_name}: #{e.message}"
  end

  def create_dive_picture(species)
    picture = @dive.pictures.build

    if @identification.image.attached?
      picture.source = :user_uploaded
      picture.photo.attach(@identification.image.blob)
    elsif species.default_photo.attached?
      picture.source = :species_default
      picture.photo.attach(species.default_photo.blob)
    else
      # If there is no image at all, we skip creating the picture association
      return
    end

    picture.save!
    PictureSpecy.create!(picture: picture, species: species)
  end
end
