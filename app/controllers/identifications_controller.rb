require "open-uri"

class IdentificationsController < ApplicationController
  def index
    @dive = Dive.find_by(id: params[:dive_id])
    if params[:identification_id].present?
      @identification = current_user.identifications.find(
        params[:identification_id]
      )

      @results = @identification.results.map(&:deep_symbolize_keys)
    end
  end

  def create
    @dive = Dive.find_by(id: params[:dive_id])

    upload = identification_params[:upload]
    camera = identification_params[:camera]
    image = upload || camera

    observation = identification_params.slice(
      :color,
      :size,
      :shape,
      :behavior
    ).compact_blank

    dive_context = identification_params.slice(
      :location,
      :dive_site,
      :date,
      :depth,
      :habitat
    ).compact_blank

    additional_info = identification_params[:additional_info]

    if image.blank? && observation.blank? && dive_context.blank? && additional_info.blank?
      flash.now[:alert] = "Please provide a description or upload an image."
      render :index, status: :unprocessable_entity
      return
    end

    user_prompt = SpeciesIdUserPrompt.call(
      observation: observation,
      dive_context: dive_context,
      additional_info: additional_info
    )

    @identification = current_user.identifications.create!(
      dive: @dive,
      user_prompt: user_prompt,
      status: :pending
    )

    begin
      if image.present?
        image.tempfile.rewind
      end

      @results = IdentificationService.new(
        user_prompt: user_prompt,
        image: image
      ).call

      if @results.blank?
        flash.now[:alert] = "The identification service didn't return any results. Please try again."
        render :index, status: :unprocessable_entity
        return
      end

      @identification.update!(
        results: @results
      )

    rescue StandardError => e
      flash.now[:alert] =
        "We encountered an issue connecting to the AI service. Please try again later."

      render :index, status: :unprocessable_entity
      return
    end

    if image.present?
      # Rewind the file so ActiveStorage can read it from the beginning
      image.tempfile.rewind

      @identification.image.attach(
        io: image.tempfile,
        filename: image.original_filename,
        content_type: image.content_type
      )
    end

    respond_to do |format|
      format.html { render :index, status: :unprocessable_entity }
      format.turbo_stream
    end
  end

  def details
    @scientific_name = params[:scientific_name].to_s.strip
    @common_name = params[:common_name].to_s.strip
    @dive_id = params[:dive_id]

    @identification = current_user.identifications.find(
      params[:identification_id]
      )

    @result = @identification.results.find do |result|
      result["scientific_name"].to_s.strip == @scientific_name
    end

    if @result.blank?
      redirect_to identification_path(
        identification_id: @identification.id
      ), alert: "Unable to find this species in the identification results."
      return
    end

    cache_key = "identification/#{@identification.id}/species_details/#{@scientific_name.downcase}"

    @details = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      SpeciesDetailsService.new(
        scientific_name: @scientific_name,
        common_name: @common_name,
        inaturalist: @result["inaturalist"]
      ).call
    end

    @details ||= {
      "scientific_name" => @scientific_name,
      "common_name" => @common_name
    }
  end

  def confirm
    @scientific_name = params[:scientific_name].to_s.strip
    @common_name = params[:common_name].to_s.strip
    @default_photo_url = params[:default_photo_url]

    @identification = current_user.identifications.find(
      params[:identification_id]
    )

    @species = Species.find_by(
      scientific_name: @scientific_name
    )

    @dive = current_user.dives.find_by(
      id: params[:dive_id]
    )

    @trip = current_user.trips.find_by(
      id: params[:trip_id]
    )

    if @trip
      @dives = @trip.dives.order(date: :desc)
      if @dive.present?
        index = @dives.index(@dive)
        @dive_number = @dives.length - index if index
      end
    else
      @trips = current_user.trips.order(created_at: :desc)
    end
  end

  def save
    @identification = current_user.identifications.find(
      params[:identification_id]
    )

    dive_id = params[:dive_id]

    if dive_id.blank?
      redirect_to identification_path,
                  alert: "Please choose a dive first."
      return
    end

    @dive = current_user.dives.find(dive_id)

    scientific_name = params[:scientific_name].to_s.strip
    common_name = params[:common_name].to_s.strip

    # --- STEP 1: Find or Initialize the Species ---
    @species = Species.find_or_initialize_by(scientific_name: scientific_name)

    @species.name = common_name.presence || scientific_name if @species.new_record?
    @species.category = Category.first if @species.new_record?

    # Download the Wikipedia/iNaturalist image instead of using AI
    if !@species.default_photo.attached? && params[:default_photo_url].present?
      begin
        downloaded_image = URI.open(params[:default_photo_url])
        @species.default_photo.attach(
          io: downloaded_image,
          filename: "#{scientific_name.parameterize}-default.jpg",
          # ActiveStorage will infer content type from the file, but we can safely default to jpeg
          content_type: 'image/jpeg'
        )
      rescue StandardError => e
        Rails.logger.error "Failed to download reference image: #{e.message}"
      end
    end

    @species.save!

    # --- STEP 2: Create the Dive's Picture Record ---
    @picture = @dive.pictures.build

    if @identification.image.attached?
      @picture.source = :user_uploaded
      @picture.photo.attach(@identification.image.blob)

    elsif @species.default_photo.attached?
      @picture.source = :species_default
      @picture.photo.attach(@species.default_photo.blob)
    end

    # --- STEP 3: Save and Associate ---
    # We only save the picture if it actually has a photo attached
    if @picture.photo.attached? && @picture.save!
      PictureSpecy.create!(picture: @picture, species: @species)
    end

    @identification.update!(
      status: :confirmed,
      species: @species,
      dive: @dive
    )

    redirect_to dive_path(@dive), notice: "Successfully added #{@species.name} to your dive!"
  end

  private

  def identification_params
    params.require(:identification).permit(
      :upload,
      :camera,
      :color,
      :size,
      :shape,
      :behavior,
      :location,
      :dive_site,
      :date,
      :depth,
      :habitat,
      :additional_info
    )
  end
end
