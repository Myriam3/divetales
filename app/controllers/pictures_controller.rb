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

  def bulk_create
    @dive = policy_scope(Dive).find(params.require(:pictures_bulk)[:dive_id])
    authorize Picture.new(dive: @dive), :create?

    photos = params[:pictures_bulk][:photos] || []
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

  def index
    @pictures = policy_scope(Picture).includes(dive: { location: :country }, species: []).order(date_time: :desc)
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

  def edit
    @picture = Picture.find(params[:id])
    authorize @picture, :edit?
    @trips = current_user.trips
    @selected_trip_id = @picture.dive.trip_id
    @selected_dive_id = @picture.dive_id
    @dives = @picture.dive.trip.dives
  end

  def update
    @picture = Picture.find(params[:id])
    authorize @picture, :update?
    if @picture.update(picture_params)
      if @picture.photo.attached?
        updated_metadata = @picture.photo.blob.metadata.merge(
          "camera_model" => params[:picture][:camera_model],
          "date_taken" => params[:picture][:date_taken]
        )
        @picture.photo.blob.update(metadata: updated_metadata)
      end

      redirect_to @picture, notice: "Photo details updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @picture = Picture.find(params[:id])
    authorize @picture
    dive = @picture.dive
    @picture.destroy

    if params[:return_to] == "dive"
      redirect_to dive_path(dive, anchor: "pictures"), notice: "Photo successfully deleted."
    else
      redirect_to pictures_path, notice: "Photo successfully deleted."
    end
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
