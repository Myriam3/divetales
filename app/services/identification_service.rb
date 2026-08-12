class IdentificationService
  def initialize(image:, description:)
    @image = image
    @description = description
  end

  def call
    ai_results = AiIdService.new(
      image: @image,
      description: @description
    ).call

    api_results = ApiIdService.new(ai_results).call

    combine_results(ai_results, api_results)
  end

  private

  def combine_results(ai_results, api_results)
  end
end
