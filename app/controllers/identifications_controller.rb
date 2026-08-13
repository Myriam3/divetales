class IdentificationsController < ApplicationController
  def index
  end

  def create
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

    @results = IdentificationService.new(
      user_prompt: user_prompt,
      image: image
    ).call

    respond_to do |format|
      format.html { render :index, status: :unprocessable_entity }
      format.turbo_stream
    end
  end

  def confirm
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
