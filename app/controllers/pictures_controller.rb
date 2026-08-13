class PicturesController < ApplicationController
  skip_after_action :verify_authorized, only: %i[new create]
  def new
    @picture = Picture.new
  end

  def create
    @picture = Picture.new(picture_params)
    dive = Dive.find(1)
    @picture.dive = dive
    puts @picture.valid?
    @picture.errors
    if @picture.save
      redirect_to pictures_path, notice: "Uploaded!"
    else
      render :new
    end
  end

  def index
    @pictures = Picture.all
  end

  private

  def picture_params
    params.require(:picture).permit(photos: [])
  end
end
