class AiIdService
  def initialize(image:, user_prompt:)
    @image = image
    @user_prompt = user_prompt
  end

  def call
    chat = RubyLLM.chat(model: "gpt-5.4-mini").with_instructions(SpeciesIdSystemPrompt::SYSTEM_PROMPT)
    response =
      if @image.present?
        chat.ask(@user_prompt, with: @image)
      else
        chat.ask(@user_prompt)
      end
    JSON.parse(response.content)
  end
end
