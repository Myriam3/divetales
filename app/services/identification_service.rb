class IdentificationService
  def initialize(image:, user_prompt:)
    @image = image
    @user_prompt = user_prompt
  end

  def call
    ai_results = AiIdService.new(
      image: @image,
      user_prompt: @user_prompt
    ).call

    ai_results["identifications"].map do |identification|
      scientific_name = identification["scientific_name"]

      inaturalist = InaturalistService.new(
        query: scientific_name
      ).call

      if inaturalist.blank?
        inaturalist = []
      end

      {
        scientific_name: scientific_name,
        common_name: identification["common_name"],
        confidence: identification["confidence"],
        reasoning: identification["reasoning"],
        evidence: identification["evidence"],
        uncertainty: identification["uncertainty"],
        inaturalist: inaturalist
      }
    end
  end
end
