# require "open-uri"
require "json"

class SpeciesDetailsService
  def initialize(scientific_name:, common_name:, inaturalist:)
    @scientific_name = scientific_name
    @common_name = common_name
    @inaturalist = inaturalist
  end

  def call
   details = generate_details

    details["default_photo_url"] ||= find_photo_url
    details["wikipedia_url"] ||= find_wikipedia_url

    details
  end

  private

  def user_prompt
    <<~PROMPT
      Candidate species:
      Common name: #{@common_name}
      Scientific name: #{@scientific_name}

      iNaturalist information:
      #{@inaturalist.to_json}

      Use the candidate species above as the subject of this response.

      IMPORTANT:
      - Do not change the scientific_name.
      - Do not substitute a different species.
      - The scientific_name "#{@scientific_name}" is authoritative.
      - The common_name "#{@common_name}" is the common name associated with this candidate.
      - If iNaturalist information is available, use it as the taxonomic reference.
      - If iNaturalist information is empty, provide the best available details based on your marine biology knowledge.
      - Do not invent iNaturalist information.
      - If iNaturalist contains a default photo URL, return it unchanged as default_photo_url.
      - If iNaturalist does not contain a default photo URL, return default_photo_url as null.
    PROMPT
  end

  def generate_details
    chat = RubyLLM.chat(
      model: "gpt-5.4-mini"
    ).with_instructions(SpeciesDetailsSystemPrompt::SYSTEM_PROMPT)

    response = chat.ask(user_prompt)

    details = JSON.parse(response.content)

    matching_taxon = @inaturalist.find do |taxon|
      taxon["scientific_name"].to_s.downcase == @scientific_name.downcase
    end

    details["default_photo_url"] =
      matching_taxon&.dig("default_photo_url")

    details["wikipedia_url"] =
      matching_taxon&.dig("wikipedia_url")

    details
  end

  def find_photo_url
    @inaturalist
      .find { |taxon| taxon["default_photo_url"].present? }
      &.dig("default_photo_url")
  end

  def find_wikipedia_url
    @inaturalist
      .find { |taxon| taxon["wikipedia_url"].present? }
      &.dig("wikipedia_url")
  end
end
