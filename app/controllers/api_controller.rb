class ApiController < ApplicationController
  def mapbox
    authorize :api, :mapbox?
    puts ENV.fetch("MAPBOX_PUBLIC_TOKEN", nil)
    render json: {
      token: ENV.fetch("MAPBOX_PUBLIC_TOKEN", nil),
      style: "mapbox://styles/mapbox/streets-v12"
    }
  end
end
