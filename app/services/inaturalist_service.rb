require "open-uri"
require "json"
require "uri"

class InaturalistService
  BASE_URL = "https://api.inaturalist.org/v1/taxa"

  def initialize(query:)
    @query = query.gsub(/\s+spp?\.?$/i, "")
  end

  def call
    search_taxa
  end

  private

  def search_taxa
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(q: @query)

    response = URI.open(uri)

    data = JSON.parse(response.read)

    data["results"].first(3).map do |taxon|
      wikipedia_url = taxon["wikipedia_url"]

      default_photo_url =
        taxon.dig("default_photo", "medium_url") ||
        WikipediaImageService.new(
          wikipedia_url: wikipedia_url
        ).call

      {
        id: taxon["id"],
        scientific_name: taxon["name"],
        common_name: taxon["preferred_common_name"],
        default_photo_url: default_photo_url,
        wikipedia_url: wikipedia_url
      }
    end
  rescue OpenURI::HTTPError, SocketError, Timeout::Error => e
    Rails.logger.error("iNaturalist error: #{e.message}")
    []
  end
end
