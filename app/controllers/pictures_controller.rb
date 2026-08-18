class PicturesController < ApplicationController
  skip_after_action :verify_authorized, only: %i[new create]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  def new
    @trips = policy_scope(Trip).select(:id, :title)

    if params[:dive_id].present?
      dive = policy_scope(Dive).includes(:trip).find(params[:dive_id])
      @picture = Picture.new(dive: dive)
      @selected_trip_id = dive.trip_id
      @selected_dive_id = dive.id
      @dives = dive.trip.dives.select(:id, :dive_site_name, :date).order(date: :desc)
    else
      @picture = Picture.new
      @selected_trip_id = nil
      @selected_dive_id = nil
      @dives = []
    end
  end

  def create
    @dive = policy_scope(Dive).find(params.require(:picture)[:dive_id])
    @picture = @dive.pictures.new(picture_params)
    authorize @picture

    if @picture.save
      redirect_to picture_path(@picture), notice: "Uploaded!"
    else
      @trips = policy_scope(Trip).includes(:dives)
      @selected_trip_id = @dive&.trip_id
      @selected_dive_id = @dive&.id
      @dives = @dive&.trip&.dives || []
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @pictures = policy_scope(Picture).includes(dive: { location: :country }, species: [])
  end

  def show
    @picture = Picture.includes(:dive, :species).find(params[:id])
    authorize @picture

    @related_species = related_species
    @related_categories = related_categories
  end

  def dives_for_trip
    @trip = policy_scope(Trip).find(params[:trip_id])
    authorize @trip, :dives_for_trip?
    @dives = @trip.dives.includes(:location).order(date: :desc)
    @selected_dive_id = params[:selected_dive_id]

    respond_to do |format|
      format.turbo_stream
    end
  end

  def not_found
    render plain: "Not found", status: :not_found
  end

  private

  def picture_params
    params.require(:picture).permit(:photo, :dive_id)
  end

  def related_species
    species = @picture.species.includes(:pictures).limit(10)
    species.each_with_object({}) do |s, result|
      result[s] = s.pictures.where.not(id: @picture.id).distinct.limit(10)
    end
  end

  def related_categories
    categories = @picture.species.includes(:category).map(&:category).uniq
    categories.each_with_object({}) do |category, result|
      pictures = Picture
                 .joins(:species)
                 .where(species: { category_id: category.id })
                 .where.not(id: @picture.id)
                 .distinct
                 .includes(:dive, :species)
                 .limit(10)
      result[category] = pictures
    end
  end
end
