class DiveSitesController < ApplicationController
  def index
    if params[:query].present?
      @dive_sites = DiveSite.where("name ILIKE ?", "%#{params[:query]}%")
    else
      @dive_sites = []
    end
    render json: @dive_sites.as_json(only: %i[id name latitude longitude])
  end
end
