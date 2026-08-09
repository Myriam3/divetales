class IdentificationsController < ApplicationController
  def index
  end

  def create
    description = identification_params[:description]
    upload = identification_params[:upload]
    camera = identification_params[:camera]
    image = upload || camera

    if description.blank? && upload.blank? && camera.blank?
      flash.now[:alert] = "Please provide a description or upload an image."
      render :index, status: :unprocessable_entity
      return
    end

    @results = IdentificationService.new(
      description: description,
      image: image
    ).call

    render :index
  end

  def confirm
  end

  def save
  end

  private

  def identification_params
    params.require(:identification).permit(:description, :upload, :camera)
  end
end
