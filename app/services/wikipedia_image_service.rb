require "open-uri"
require "json"
require "uri"

class WikipediaImageService
  BASE_URL = "https://en.wikipedia.org/w/api.php"

  def initialize(wikipedia_url:)
    @wikipedia_url = wikipedia_url
  end

  def call
    return nil if @wikipedia_url.blank?

    title = URI.decode_www_form_component(
      URI.parse(@wikipedia_url).path.split("/").last
    )

    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(
      action: "query",
      format: "json",
      prop: "pageimages",
      pithumbsize: 600,
      titles: title
    )

    response = URI.open(
      uri,
      "User-Agent" => "Divetales/1.0"
    )

    data = JSON.parse(response.read)

    page = data.dig("query", "pages")&.values&.first

    page&.dig("thumbnail", "source")
  rescue OpenURI::HTTPError, SocketError, Timeout::Error, JSON::ParserError => e
    Rails.logger.error("Wikipedia image error: #{e.message}")
    nil
  end
end
