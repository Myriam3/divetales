class AiIdService
  def initialize(image:, user_prompt:)
    @image = image
    @user_prompt = user_prompt
  end

  def call
    Rails.logger.debug "=== AI SERVICE: START ==="
    chat = RubyLLM.chat(model: "gpt-5.4-mini").with_instructions(SpeciesIdSystemPrompt::SYSTEM_PROMPT)
     Rails.logger.debug "=== AI SERVICE: CHAT CREATED ==="
    response =
      if @image.present?
        Rails.logger.debug "=== AI SERVICE: SENDING IMAGE ==="
        chat.ask(@user_prompt, with: @image)
      else
        Rails.logger.debug "=== AI SERVICE: SENDING TEXT ONLY ==="
        chat.ask(@user_prompt)
      end
          Rails.logger.debug "=== AI SERVICE: RESPONSE RECEIVED ==="
    Rails.logger.debug response.inspect
    parsed_response = JSON.parse(response.content)
    Rails.logger.debug "=== AI SERVICE: JSON PARSED ==="
    Rails.logger.debug parsed_response.inspect
    parsed_response
  end
end
