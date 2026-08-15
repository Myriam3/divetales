class IdentificationsController < ApplicationController
  def index
  end

  def create
    upload = identification_params[:upload]
    camera = identification_params[:camera]
    image = upload || camera

    blob = nil

    if image.present?
      blob = ActiveStorage::Blob.create_and_upload!(
        io: image.tempfile,
        filename: image.original_filename,
        content_type: image.content_type
      )

      session[:identification_image_blob_id] = blob.id
      image.tempfile.rewind
    else
      session.delete(:identification_image_blob_id)
    end

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

    @results = IdentificationService.new(
      user_prompt: user_prompt,
      image: image
    ).call

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
