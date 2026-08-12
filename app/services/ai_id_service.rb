class AiIdService
  def initialize(image:, description:, dive: nil)
    @image = image
    @description = description
    @dive = dive
  end

  def call
    chat = RubyLLM.chat(model: "gpt-5.4-mini").with_instructions(SpeciesIdSystemPrompt::SYSTEM_PROMPT)
    response =
      if @image.present?
        chat.ask(user_prompt, with: @image)
      else
        chat.ask(user_prompt)
      end
    JSON.parse(response.content)
  end

  private

  def user_prompt
    SpeciesIdUserPrompt.call(
      description: @description,
      dive: @dive
    )
  end
end
