require "open-uri"
require "json"

class SpeciesDetailsService
  def initialize(scientific_name:, common_name:)
    @scientific_name = scientific_name
    @common_name = common_name
  end

  def call
    taxon = fetch_inaturalist_taxon
    return nil unless taxon
    generate_details(taxon)
  end

  private

  def user_prompt(taxon)
    <<~PROMPT
      Candidate species:
      Common name: #{@common_name}
      Scientific name: #{@scientific_name}

      Verified iNaturalist information:
      #{taxon.to_json}
    PROMPT
  end

  def fetch_inaturalist_taxon
    url = "https://api.inaturalist.org/v1/taxa?q=#{URI.encode_www_form_component(@scientific_name)}"

    response = JSON.parse(URI.open(url).read)

    taxon = response["results"]&.first

    return nil unless taxon
    {
      id: taxon["id"],
      name: taxon["name"],
      common_name: taxon["preferred_common_name"],
      rank: taxon["rank"],
      ancestor_ids: taxon["ancestor_ids"],
      wikipedia_url: taxon["wikipedia_url"],
      default_photo: taxon.dig("default_photo", "medium_url")
    }
    rescue OpenURI::HTTPError, SocketError, Timeout::Error => e
    Rails.logger.error("iNaturalist error: #{e.message}")
    nil
  end

  def generate_details(taxon)
    chat = RubyLLM.chat(
      model: "gpt-5.4-mini"
    ).with_instructions(SpeciesDetailsSystemPrompt::SYSTEM_PROMPT)

    response = chat.ask(user_prompt(taxon))

    JSON.parse(response.content)
  end
end
