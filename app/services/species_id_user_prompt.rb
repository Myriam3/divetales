class SpeciesIdUserPrompt
  def self.call(description:, dive: nil)
    <<~PROMPT
      User description:
      #{description.presence || 'None provided.'}

      Dive context:
      #{dive_context(dive)}
    PROMPT
  end

  private

  def self.dive_context(dive)
    return "None provided." unless dive

    {
      location: dive.location,
      date: dive.date,
      depth: dive.depth,
      water_temperature: dive.water_temperature,
      visibility: dive.visibility,
      habitat: dive.habitat,
      notes: dive.notes
    }.compact.to_json
  end
end
