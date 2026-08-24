class PopulateSpeciesDetailsJob < ApplicationJob
  queue_as :default

  def perform(species_id)
    species = Species.find(species_id)
    return if species.details.present?

    generated_details = SpeciesDetailsService.new(
      scientific_name: species.scientific_name,
      common_name: species.name,
      inaturalist: []
    ).call

    species.update!(details: generated_details)

    Turbo::StreamsChannel.broadcast_replace_to(
      "species-details-#{species.id}",
      target: "species-details-frame-#{species.id}",
      partial: "shared/species_info",
      locals: { details: species.details }
    )
  rescue StandardError => e
    Rails.logger.error("Species model details generation failed: #{e.message}")

    Turbo::StreamsChannel.broadcast_update_to(
      "species-details-#{species.id}",
      target: "species-details-frame-#{species.id}",
      html: "<div class='alert alert-danger'>Failed to load species details. Please try again later.</div>"
    )
  end
end
