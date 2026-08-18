class DivesController < ApplicationController
  def index
    @dives = policy_scope(Dive).order(date: :desc)

    @countries_count = @dives.map { |dive| dive.location.country }.compact.uniq.count
    @pictures_count = @dives.flat_map(&:pictures).uniq.count
    @species_count = @dives.flat_map { |dive| dive.pictures.flat_map(&:species) }.uniq.count
  end

  def new
    if params[:trip_id]
      @trip = Trip.find(params[:trip_id])
      @dive = @trip.dives.new
    else
      @dive = Dive.new
    end

    authorize @dive
  end

  def create
    @trip = Trip.find(params[:trip_id]) if params[:trip_id]

    @dive = @trip ? @trip.dives.new(dive_params) : Dive.new(dive_params)

    authorize @dive

    if @dive.save
      redirect_to @dive, notice: "Dive created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @dive = Dive.find(params[:id])
    @species = @dive.pictures
                    .includes(:species)
                    .flat_map(&:species)
                    .uniq
    authorize @dive
  end

  def destroy
    @dive = Dive.find(params[:id])
    authorize @dive
  end

  def display_name
    dive_site_name.presence || location.name
  end

  private

  def dive_params
    params.require(:dive).permit(
      :date,
      :dive_site_name,
      :location_id,
      :duration,
      :max_depth,
      :avg_depth,
      :max_temp,
      :min_temp,
      :avg_temp,
      :latitude,
      :longitude,
      :note,
      dive_types: []
    )
  end
end
