class DivesController < ApplicationController
  def index
    if params[:trip_id].present?
      @trip = Trip.find(params[:trip_id])
      @dives = policy_scope(@trip.dives).order(date: :desc)
    else
      @dives = policy_scope(Dive).order(date: :desc)
    end

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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal-container",
            partial: "dives/new_dive_modal",
            locals: { dive: @dive }
          )
        end

        # Fallaback
        format.html { redirect_to [@trip, @dive], notice: "Dive created!" }
      end
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
    @dive.destroy

    redirect_to params[:trip_id] ? trip_path(@dive.trip) : dives_path, notice: "Dive deleted!"
  end

  private

  def dive_params
    params.require(:dive).permit(
      :date,
      :start_time,
      :end_time,
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
      :tank_type,
      :gauge_pressure_start,
      :gauge_pressure_end,
      :note,
      :depth_over_time,
      dive_types: []
    ).tap do |data|
      data.delete(:dive_types) if data[:dive_types].blank?
    end
  end
end
