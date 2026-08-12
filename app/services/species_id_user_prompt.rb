class SpeciesIdUserPrompt
  def self.call(observation:, dive_context:, additional_info: nil)
    <<~PROMPT
      User observation:
      #{observation.presence || "None provided."}

      Dive context:
      #{dive_context.presence || "None provided."}

      Additional information:
      #{additional_info.presence || "None provided."}
    PROMPT
  end
end
