class SpeciesDetailsJob < ApplicationJob
  queue_as :default

  def perform(identification_id, scientific_name, picture_id = nil)
    identification = Identification.find(identification_id)

    scientific_name = scientific_name.to_s.strip

    result = identification.results.find do |result|
      result["scientific_name"].to_s.strip == scientific_name
    end

    return unless result

    # Don't generate again if details already exist
    existing_details = identification.details || {}

    return if existing_details[scientific_name].present? &&
              existing_details[scientific_name]["status"] == "completed"

    generated_details = SpeciesDetailsService.new(
      scientific_name: result["scientific_name"],
      common_name: result["common_name"],
      inaturalist: result["inaturalist"] || []
    ).call

    details = identification.details || {}

    details[scientific_name] = generated_details.merge(
      "status" => "completed"
    )

    identification.update!(details: details)

    stream_name = "identification-details-#{identification.id}-#{scientific_name.parameterize}"

    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name,
      target: "species-details-#{identification.id}-#{scientific_name.parameterize}",
      partial: "identifications/species_details",
      locals: {
        details: details[scientific_name],
        scientific_name: scientific_name,
        common_name: result["common_name"],
        identification_id: identification.id,
        dive_id: identification.dive_id,
        default_photo_url: details[scientific_name]["default_photo_url"],
        picture_id: picture_id
      }
    )
    Rails.logger.info(
      "BROADCASTING SPECIES DETAILS: #{identification.id} / #{scientific_name}"
    )
  rescue StandardError => e
    Rails.logger.error(
      "Species details generation failed: #{e.message}"
    )

    details = identification.details || {}

    details[scientific_name] = {
      "status" => "failed"
    }

    identification.update!(details: details)

    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name,
      target: "species-details-#{identification.id}-#{scientific_name.parameterize}",
      partial: "identifications/species_details",
      locals: {
        details: details[scientific_name],
        scientific_name: scientific_name,
        common_name: result&.[]("common_name"),
        identification_id: identification.id,
        dive_id: identification.dive_id,
        default_photo_url: details[scientific_name]["default_photo_url"],
        picture_id: picture_id
      }
    )
  end
end
