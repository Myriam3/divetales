class AiIdService
  def initialize(image:, user_prompt:)
    @image = image
    @user_prompt = user_prompt
  end

  def call
    chat = RubyLLM
      .chat(model: "gpt-5.4-mini")
      .with_instructions(SpeciesIdSystemPrompt::SYSTEM_PROMPT)

    begin
      response = if @image.present?
                  chat.ask(@user_prompt, with: @image)
                else
                  chat.ask(@user_prompt)
                end
      # response = chat.ask(@user_prompt)
      parsed_response = JSON.parse(response.content)

      parsed_response
    rescue => e
      raise
    end
  end
end
