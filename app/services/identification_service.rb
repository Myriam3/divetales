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

    api_results = search_inaturalist(ai_results)

    combine_results(ai_results, api_results)
  end

  private

  def search_inaturalist(ai_results)
    ai_results["identifications"].map do |identification|
      scientific_name = identification["scientific_name"]

      {
        ai_identification: identification,
        inaturalist: InaturalistService.new(
          query: scientific_name
        ).call
      }
    end
  end

  def combine_results(ai_results, api_results)
    ai_results["identifications"].map do |identification|
      scientific_name = identification["scientific_name"]

      inaturalist_result = api_results.find do |result|
        result[:ai_identification]["scientific_name"] == scientific_name
      end

      {
        scientific_name: scientific_name,
        common_name: identification["common_name"],
        confidence: identification["confidence"],
        reasoning: identification["reasoning"],
        evidence: identification["evidence"],
        uncertainty: identification["uncertainty"],
        inaturalist: inaturalist_result&.dig(:inaturalist) || []
      }
    end
  end
end
