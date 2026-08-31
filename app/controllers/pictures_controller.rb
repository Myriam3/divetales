class PicturesController < ApplicationController
  before_action :set_picture, only: %i[show edit update destroy generate_species_details]
  before_action :set_form_data, only: %i[new edit]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  def index
    @pictures = index_pictures

    # Available filters
    load_filter_options(@pictures)

    # Filter result
    @pictures = filtered_pictures(@pictures)
    load_active_filters
  end

  def show
    @related_species = related_species
    @related_categories = related_categories
  end

  def new
    @picture = Picture.new(dive_id: @selected_dive_id)
    authorize @picture
  end

  def create
    @dive = policy_scope(Dive).find(params.require(:picture)[:dive_id])
    @picture = @dive.pictures.new(picture_params)
    authorize @picture

    if @picture.save
      redirect_to picture_path(@picture), notice: "Uploaded!"
    else
      set_form_data(@dive)
      render :new, status: :unprocessable_entity
    end
  end

  def bulk_create
    @dive = policy_scope(Dive).find(params.require(:pictures_bulk)[:dive_id])
    authorize Picture.new(dive: @dive), :create?

    photos = params[:pictures_bulk][:photos] || []

    if photos.size > 5
      redirect_to new_picture_path(dive_id: @dive.id, trip_id: @dive.trip_id),
                  alert: "Upload failed: You cannot upload more than 5 photos at a time."
      return
    end

    created = []
    errors = []

    photos.each do |photo|
      picture = @dive.pictures.new(photo: photo)
      if picture.save
        created << picture
      else
        errors << picture.errors.full_messages
      end
    end

    if errors.empty?
      redirect_to dive_path(@dive), notice: "#{created.size} photos uploaded!"
    else
      redirect_to new_picture_path(dive_id: @dive.id, trip_id: @dive.trip_id),
                  alert: "Some photos failed: #{errors.flatten.join(', ')}"
    end
  end

  def edit
  end

  def update
    if @picture.update(picture_params)
      update_metadata if @picture.photo.attached?
      redirect_to @picture, notice: "Photo details updated successfully!"
    else
      set_form_data(@picture.dive)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    dive = @picture.dive
    @picture.destroy

    if params[:return_to] == "dive"
      redirect_to dive_path(dive, anchor: "pictures"), notice: "Photo successfully deleted."
    else
      redirect_to pictures_path, notice: "Photo successfully deleted."
    end
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

  def generate_species_details
    @species = Species.find(params[:species_id])

    PopulateSpeciesDetailsJob.perform_later(@species.id)

    head :no_content
  end

  def bulk_destroy
    @pictures = Picture.where(id: params[:picture_ids])

    @pictures.each { |picture| authorize picture, :destroy? }

    dive = @pictures.first&.dive

    deleted_count = @pictures.destroy_all.count

    if params[:return_to] == "dive" && dive
      redirect_to dive_path(dive, anchor: "pictures"), notice: "Successfully deleted #{deleted_count} photos.",
                                                       status: :see_other
    else
      redirect_to pictures_path, notice: "Successfully deleted #{deleted_count} photos.", status: :see_other
    end
  end

  def lightbox
    authorize Picture, :lightbox?

    @lightbox_pictures = load_lightbox_pictures
    @lightbox_selected_picture_id = params[:picture_id]

    respond_to do |format|
      format.turbo_stream
      puts @lightbox_selected_picture_id
      format.html
    end
  end

  private

  def set_picture
    @picture = Picture.includes(:dive, :species).find(params[:id])
    authorize @picture
  end

  def set_form_data(dive = nil)
    @trips = policy_scope(Trip).select(:id, :title)

    target_dive = dive || @picture&.dive
    target_dive ||= policy_scope(Dive).find_by(id: params[:dive_id]) if params[:dive_id].present?

    if target_dive
      @selected_trip_id = target_dive.trip_id
      @selected_dive_id = target_dive.id
      @dives = target_dive.trip.dives.select(:id, :dive_site_name, :date, :start_time, :dive_number).order(date: :desc)
    else
      @selected_trip_id = nil
      @selected_dive_id = nil
      @dives = []
    end
  end

  def update_metadata
    updated_metadata = @picture.photo.blob.metadata.merge(
      "camera_model" => params[:picture][:camera_model],
      "date_taken" => params[:picture][:date_taken]
    )

    @picture.update!(date_time: DateTime.parse(params[:picture][:date_taken])) if params[:picture][:date_taken].present?

    @picture.photo.blob.update(metadata: updated_metadata)
  end

  def picture_params
    params.require(:picture).permit(:photo, :dive_id, :date_time)
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

  def load_lightbox_pictures
    if params[:trip_id]
      Trip.find(params[:trip_id])
          .dives
          .includes(:pictures)
          .flat_map(&:pictures)

    elsif params[:dive_id]
      Dive.find(params[:dive_id])
          .pictures

    elsif params[:location_id]
      Location.find(params[:location_id])
              .dives
              .includes(:pictures)
              .flat_map(&:pictures)
    else
      Picture.none
    end
  end

  def load_filter_options(pictures)
    @trips = current_user.trips.order(:title)
    selected_trip = nil

    if params[:trip_id].present?
      selected_trip = @trips.find_by(id: params[:trip_id])
      @trips = filtered_trips(@trips)
    end

    @countries = filtered_countries(selected_trip)
    @locations_by_country = filtered_locations(selected_trip)
    @years = filtered_years(selected_trip)

    @species = Species.joins(:pictures)
                      .where(pictures: { id: pictures.select(:id) })
                      .includes(:category)
                      .distinct
                      .order(:name)
    @selected_species = params[:species_id]&.present? ? @species.find_by(id: params[:species_id]) : nil
    # @species = @species.where(category_id: params[:category_id]) if params[:category_id].present?

    @categories = @species
                  .map(&:category)
                  .compact
                  .uniq
                  .sort_by(&:name)
                  .group_by(&:classification)
  end

  def filtered_trips(trips)
    year = params[:year].to_i
    return trips unless year.positive?

    start_year = Date.new(year, 1, 1)
    next_year = start_year.next_year

    puts start_year
    puts next_year

    trips
      .where(
        start_date: start_year...next_year
      )
      .or(
        trips.where(
          end_date: start_year...next_year
        )
      )
      .order(:title)
  end

  def filtered_countries(selected_trip)
    if selected_trip.present?
      selected_trip.countries
    else
      Country.joins(:trips)
             .where(trips: { user_id: current_user.id })
             .distinct
             .order(:name)
    end
  end

  def filtered_years(selected_trip)
    years = []
    @selected_trip = selected_trip

    if selected_trip.present?
      start_year = selected_trip.start_date.year
      end_year = selected_trip.end_date.year
      years = (start_year..end_year).to_a.reverse
    end

    if years.any?
      years
    else
      policy_scope(Picture)
        .joins(:dive).pluck(Arel.sql("EXTRACT(YEAR FROM dives.date)::integer")).uniq
        .sort
        .reverse
    end
  end

  def filtered_locations(selected_trip)
    locations = Location.joins(dives: :trip)
                        .where(trips: { user_id: current_user.id })

    locations = locations.where(trips: { id: selected_trip.id }) if selected_trip.present?
    locations = locations.where(country_id: params[:country_id]) if params[:country_id].present?

    locations
      .includes(:country)
      .distinct
      .order(:name)
      .group_by { |location| location.country.name }
  end

  def load_active_filters
    @active_filters = {}

    if params[:trip_id].present?
      trip = current_user.trips.find_by(id: params[:trip_id])
      @active_filters["Trip"] = trip.title if trip
    end

    if params[:country_id].present?
      country = Country.find_by(id: params[:country_id])
      @active_filters["Country"] = country.name if country
    end

    if params[:location_id].present?
      location = Location.find_by(id: params[:location_id])
      @active_filters["Location"] = location.name if location
    end

    if params[:species_id].present?
      species = Species.find_by(id: params[:species_id])
      @active_filters["Species"] = species.name if species
    end

    if params[:category_id].present?
      category = Category.find_by(id: params[:category_id])
      @active_filters["Category"] = category.name if category
    end

    return unless params[:year].present?

    @active_filters["Year"] = params[:year]
  end

  def filtered_pictures(pictures)
    # Countries
    pictures = pictures.where(countries: { id: params[:country_id] }) if params[:country_id].present?

    # Trip
    pictures = pictures.where(trips: { id: params[:trip_id] }) if params[:trip_id].present?

    # Location
    pictures = pictures.where(locations: { id: params[:location_id] }) if params[:location_id].present?

    # Category
    pictures = pictures.where(categories: { id: params[:category_id] }) if params[:category_id].present?

    # Species
    pictures = pictures.where(species: { id: params[:species_id] }) if params[:species_id].present?

    # Year
    if params[:year].present?
      year = params[:year].to_i

      if year.positive?
        start_date = Date.new(year, 1, 1)
        end_date = start_date.next_year

        pictures = pictures.where(dives: { date: start_date...end_date })
      end
    end

    sorted_pictures(pictures.distinct)
  end

  def sorted_pictures(pictures)
    case params[:sort]
    when "date_asc"
      pictures.order(date_time: :asc)
    when "date_desc"
      pictures.order(date_time: :desc)
    when "created_asc"
      pictures.order(created_at: :asc)
    else
      pictures.order(created_at: :desc)
    end
  end

  def index_pictures
    # Default
    pictures = policy_scope(Picture).includes(:species, dive: { location: :country })

    # Join country
    pictures = pictures.joins(dive: { trip: :countries }) if params[:country_id].present?

    # Join trip
    pictures = pictures.joins(dive: :trip) if params[:trip_id].present? || params[:sort] == "trip"

    # Join location
    pictures = pictures.joins(dive: :location) if params[:location_id].present? || params[:sort] == "location"

    # Join category
    pictures = pictures.joins(species: :category) if params[:category_id].present?

    # Join species
    pictures = pictures.joins(:species) if params[:species_id].present?

    # Join dives
    pictures = pictures.joins(:dive) if params[:year].present?

    pictures
  end
end
