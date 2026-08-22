class IdentificationJob < ApplicationJob
  queue_as :default

  def perform(identification_id)
    identification = Identification.find(identification_id)

    image = identification.image

    @results = IdentificationService.new(
      user_prompt: identification.user_prompt,
      image: image
    ).call

    if @results.blank?
      identification.update!(
        status: :failed
      )
      return
    end

    identification.update!(
      results: @results,
      status: :completed
    )

  rescue StandardError => e
    Rails.logger.error(
      "IdentificationJob failed for Identification #{identification_id}: #{e.class}: #{e.message}"
    )

    identification&.update!(
      status: :failed
    )

    raise
  end
end
