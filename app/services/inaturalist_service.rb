require "open-uri"
require "json"
require "uri"

class InaturalistService
  BASE_URL = "https://api.inaturalist.org/v2"

  def initialize(query:)
    @query = query
  end

  def call
    search_taxa
  end

  private

  def search_taxa
    uri = URI("#{BASE_URL}/taxa/autocomplete")
    uri.query = URI.encode_www_form(q: @query)

    response = URI.open(uri)

    data = JSON.parse(response.read)

    data["results"].first(3).map do |taxon|
      {
        id: taxon["id"],
        scientific_name: taxon["name"],
        common_name: taxon["preferred_common_name"]
      }
    end
  end
end
