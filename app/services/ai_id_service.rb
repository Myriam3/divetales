class AiIdService
  def initialize(image:, user_prompt:)
    @image = image
    @user_prompt = user_prompt
  end

  def call
    Rails.logger.debug "=== AI SERVICE: START ==="

    chat = RubyLLM
      .chat(model: "gpt-5.4-mini")
      .with_instructions(SpeciesIdSystemPrompt::SYSTEM_PROMPT)

    Rails.logger.debug "=== AI SERVICE: CHAT CREATED ==="

    begin
      Rails.logger.debug "=== AI SERVICE: SENDING IMAGE ==="

      response = if @image.present?
                  chat.ask(@user_prompt, with: @image)
                else
                  chat.ask(@user_prompt)
                end
      # response = chat.ask(@user_prompt)
      Rails.logger.debug "=== AI SERVICE: RESPONSE RECEIVED ==="

      parsed_response = JSON.parse(response.content)

      Rails.logger.debug "=== AI SERVICE: JSON PARSED ==="
      Rails.logger.debug parsed_response.inspect

      parsed_response
    rescue => e
      Rails.logger.error "=== AI SERVICE ERROR ==="
      Rails.logger.error "#{e.class}: #{e.message}"
      raise
    end
  end
end
