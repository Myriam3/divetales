class AiIdService
  def initialze(image:, description:)
    @image = image
    @description = description
  end

  def call
    response = RubyLLM.chat.with_instructions(SpeciesIdSystemPrompt::SYSTEM_PROMPT).ask(user_prompt)
    JSON.parse(response.content)
  end

  private
end
