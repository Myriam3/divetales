class PicturesController < ApplicationController
  before_action :set_picture, only: %i[show edit update destroy]
  before_action :set_form_data, only: %i[new edit]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @pictures = policy_scope(Picture).includes(dive: { location: :country }, species: [])

    @pictures = @pictures.joins(dive: :trip).where(trips: { id: params[:trip_id] }) if params[:trip_id].present?
    if params[:location_id].present?
      @pictures = @pictures.joins(dive: :location).where(locations: { id: params[:location_id] })
    end
    @pictures = @pictures.where("pictures.date_time >= ?", params[:date_from]) if params[:date_from].present?
    @pictures = @pictures.where("pictures.date_time <= ?", params[:date_to]) if params[:date_to].present?

    @pictures = case params[:sort]
                when "date_asc"
                  @pictures.order(date_time: :asc)
                when "trip"
                  @pictures.joins(dive: :trip).order("trips.title ASC")
                when "location"
                  @pictures.joins(dive: :location).order("locations.name ASC")
                else
                  @pictures.order(date_time: :desc)
                end

    @trips = current_user.trips.order(:title)
    @locations = Location.joins(dives: :trip).where(trips: { user_id: current_user.id }).distinct.order(:name)
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
