require "open-uri"

class IdentificationsController < ApplicationController
  def index
    @dive = Dive.find_by(id: params[:dive_id])
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
    begin
      Rails.logger.debug "=== BEFORE AI ==="
      Rails.logger.debug "IMAGE: #{image.inspect}"
      Rails.logger.debug "USER PROMPT: #{user_prompt.inspect}"
      if image.present?
        image.tempfile.rewind
      end

      @results = IdentificationService.new(
        user_prompt: user_prompt,
        image: nil
      ).call

      Rails.logger.debug "=== AFTER AI ==="
      Rails.logger.debug "RESULTS: #{@results.inspect}"

      if @results.blank?
        flash.now[:alert] = "The identification service didn't return any results. Please try again."
        render :index, status: :unprocessable_entity
        return
      end
    rescue StandardError => e
      Rails.logger.error "=== IDENTIFICATION ERROR ==="
      Rails.logger.error "CLASS: #{e.class}"
      Rails.logger.error "MESSAGE: #{e.message}"
      Rails.logger.error e.full_message
      Rails.logger.error "============================"

      flash.now[:alert] =
        "We encountered an issue connecting to the AI service. Please try again later."

      render :index, status: :unprocessable_entity
      return
    end

    if image.present?
      # Rewind the file so ActiveStorage can read it from the beginning
      image.tempfile.rewind

      blob = ActiveStorage::Blob.create_and_upload!(
        io: image.tempfile,
        filename: image.original_filename,
        content_type: image.content_type
      )

      session[:identification_image_blob_id] = blob.id
    else
      session.delete(:identification_image_blob_id)
    end

    Rails.logger.debug "=== IDENTIFICATION RESULTS ==="
    Rails.logger.debug @results.inspect
    Rails.logger.debug "=============================="

    respond_to do |format|
      format.html { render :index, status: :unprocessable_entity }
      format.turbo_stream
    end
  end

  def details
    @scientific_name = params[:scientific_name]
    @common_name = params[:common_name]

    @details = SpeciesDetailsService.new(
      scientific_name: @scientific_name,
      common_name: @common_name
    ).call
  end

  def confirm
    @scientific_name = params[:scientific_name].to_s.strip
    @common_name = params[:common_name].to_s.strip
    @default_photo_url = params[:default_photo_url]
    @species = Species.find_by(
      scientific_name: @scientific_name
    )

    @image_blob = if session[:identification_image_blob_id].present?
                    ActiveStorage::Blob.find_by(
                      id: session[:identification_image_blob_id]
                    )
                  end
  end

  def save
    @dive = Dive.find(params[:dive_id])
    scientific_name = params[:scientific_name].to_s.strip
    common_name = params[:common_name].to_s.strip

    # --- STEP 1: Find or Initialize the Species ---
    @species = Species.find_or_initialize_by(scientific_name: scientific_name)

    if @species.new_record?
      @species.name = common_name.presence || scientific_name
      @species.category = Category.first

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
    end

    # --- STEP 2: Create the Dive's Picture Record ---
    @picture = @dive.pictures.build

    if session[:identification_image_blob_id].present?
      # User uploaded an image
      blob = ActiveStorage::Blob.find_by(id: session[:identification_image_blob_id])
      @picture.source = :user_uploaded
      @picture.photo.attach(blob)
    elsif @species.default_photo.attached?
      # User didn't upload, but we successfully saved the web image
      @picture.source = :species_default
      @picture.photo.attach(@species.default_photo.blob)
    end

    # --- STEP 3: Save and Associate ---
    # We only save the picture if it actually has a photo attached
    if @picture.photo.attached? && @picture.save
      PictureSpecy.create!(picture: @picture, species: @species)
    end

    session.delete(:identification_image_blob_id)
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
