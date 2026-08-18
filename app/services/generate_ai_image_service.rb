# app/services/generate_ai_image_service.rb
require "open-uri"
require "json"
require "net/http"

class GenerateAiImageService
  def self.call(prompt:)
    # You can use the `ruby-openai` gem here, or raw HTTP
    uri = URI("https://api.openai.com/v1/images/generations")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV['OPENAI_ACCESS_TOKEN']}"
    request["Content-Type"] = "application/json"

    # DALL-E 3 provides highly realistic, accurate imagery
    request.body = {
      model: "dall-e-3",
      prompt: "A highly realistic, scientifically accurate underwater photograph of #{prompt}. Natural lighting, clear water, wildlife photography style.",
      n: 1,
      size: "1024x1024"
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    image_url = JSON.parse(response.body).dig("data", 0, "url")

    # Download the image to a temporary file and return the IO stream
    URI.open(image_url)
  end
end
