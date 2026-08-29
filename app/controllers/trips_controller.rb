class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: %i[show edit update destroy memory memory_dive]

  def index
    @trips = policy_scope(Trip).order(start_date: :desc)
  end

  def show
    @dives = @trip.dives.order(date: :desc)
    authorize @trip
  end

  def new
    @trip = current_user.trips.new
    authorize @trip
  end

  def create
    @trip = current_user.trips.new(trip_params)
    authorize @trip

    if @trip.save
      redirect_to @trip, notice: "Trip created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: "Trip updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_cover_photo
    @trip = policy_scope(Trip).find(params[:id])
    authorize @trip, :update?

    if @trip.update(cover_photo_params)
      redirect_back fallback_location: trips_path, notice: "Trip photo updated!"
    else
      redirect_back fallback_location: trips_path, alert: "Photo could not be updated."
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: "Trip deleted."
  end

  def memory
    @dives = @trip.dives.includes(
      :location,
      pictures: { species: :category }
    )

    @pictures = @dives.flat_map(&:pictures)

    @species = @pictures.flat_map(&:species)
                        .uniq(&:id)
                        .sort_by(&:name)

    @stats = trip_stats
    @species_pictures_stats = species_pictures_stats
    @classification_pictures_stats = @pictures.flat_map(&:species)
                                              .group_by { |species| species.category.classification }
                                              .transform_values(&:count)
    @categories_by_class = categories_by_class
    @dives_by_time = dives_by_time
    @dives_by_entry = dives_by_entry
    @itinerary = build_itinerary
  end

  def memory_dive
    @dive = @trip.dives.find(params[:dive_id])

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:title, :start_date, :end_date, :info, country_ids: [])
  end

  def set_trip
    @trip = policy_scope(Trip).find(params[:id])
    authorize @trip
  end

  def trip_stats
    {
      dives_count: @dives.size,
      dive_days_count: @dives.map(&:date).compact.uniq.size,
      pictures_count: @pictures.size,
      species_count: @species.size,
      dive_site_count: @dives.filter_map(&:dive_site_name).uniq.size,
      max_depth: @dives.filter_map(&:max_depth).max,
      total_duration: @dives.filter_map(&:duration).sum,
      avg_temp: avg_temp,
      max_duration: @dives.filter_map(&:duration).max,
      countries_count: @trip.trip_countries.distinct.count,
      wreck_count: @dives.count { |dive| dive.dive_types.include?("wreck") },
      drift_count: @dives.count { |dive| dive.dive_types.include?("drift") },
      cave_count: @dives.count { |dive| dive.dive_types.include?("cave") }
    }
  end

  def species_pictures_stats
    @species_pictures_stats = @species.each_with_object(
      Hash.new { |hash, key| hash[key] = {} }
    ) do |species, stats|
      classification = species.category.classification.to_s

      picture_count = @pictures.count do |picture|
        picture.species.include?(species)
      end

      stats[classification][species] = picture_count
    end
  end

  def avg_temp
    temperatures = @dives.filter_map do |dive|
      if dive.avg_temp.present?
        dive.avg_temp.to_f
      elsif dive.min_temp.present? && dive.max_temp.present?
        (dive.min_temp.to_f + dive.max_temp.to_f) / 2
      end
    end

    return nil if temperatures.empty?

    temperatures.sum / temperatures.size
  end

  def categories_by_class
    @pictures
      .flat_map(&:species)
      .map(&:category)
      .uniq(&:id)
      .group_by(&:classification)
      .transform_values do |categories|
        categories.sort_by(&:name).map(&:name)
      end
  end

  def dives_by_time
    {
      night: @dives.count { |dive| dive.dive_types.include?("night") },
      morning: @dives.count { |dive| dive.start_time ? dive.start_time.to_datetime.hour < 12 : false },
      afternoon: @dives.count { |dive| dive.start_time ? dive.start_time.to_datetime.hour >= 12 : false }
    }
  end

  def dives_by_entry
    {
      boat: @dives.count { |dive| dive.dive_types.include?("boat") },
      shore: @dives.count { |dive| dive.dive_types.include?("shore") },
      other: @dives.size - @dives.count { |dive| dive.dive_types.include?("boat") || dive.dive_types.include?("shore") }
    }
  end

  def build_itinerary
    itinerary = []

    @dives.sort_by { |dive| [dive.date, dive.id] }.each do |dive|
      last_item = itinerary.last

      if last_item && last_item[:location].id == dive.location_id
        last_item[:end_date] = dive.date
        last_item[:dives_count] += 1
        last_item[:pictures_count] += dive.pictures.size
      else
        itinerary << {
          location: dive.location,
          start_date: dive.date,
          end_date: dive.date,
          dives_count: 1,
          pictures_count: dive.pictures.size
        }
      end
    end

    itinerary
  end

  def cover_photo_params
    params.require(:trip).permit(:cover_photo)
  end
end
