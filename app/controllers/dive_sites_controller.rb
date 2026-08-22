class DiveSitesController < ApplicationController
  def index
    if params[:query].present? || params[:location_id].present?
      @dive_sites = DiveSite.includes(:location)

      @dive_sites = @dive_sites.where("name ILIKE ?", "%#{params[:query]}%") if params[:query].present?

      @dive_sites = @dive_sites.where(location_id: params[:location_id]) if params[:location_id].present?

      @dive_sites = @dive_sites.limit(50)
    else
      @dive_sites = []
    end

    render json: @dive_sites.map { |site|
      secondary_text = if site.location.present?
                         site.location.name
                       else
                         "GPS: #{site.latitude&.round(4)}, #{site.longitude&.round(4)}"
                       end

      {
        id: site.id,
        name: site.name,
        latitude: site.latitude,
        longitude: site.longitude,
        details: secondary_text
      }
    }
  end
end
