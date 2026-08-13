class PicturesController < ApplicationController
  skip_after_action :verify_authorized, only: %i[new create]
  def new
    @picture = Picture.new
  end

  def create
    @picture = Picture.new(picture_params)
    dive = Dive.first
    @picture.dive = dive
    puts @picture.valid?
    puts @picture.errors
    if @picture.save
      redirect_to picture_path(@picture), notice: "Uploaded!"
    else
      render :new
    end
  end

  def index
    @pictures = Picture.all
  end

  def show
    @picture = Picture.find(params[:id])
    authorize @picture
  end

  private

  def picture_params
    params.require(:picture).permit(:photo)
  end
end
