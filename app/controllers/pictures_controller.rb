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
    @pictures = policy_scope(Picture).includes(dive: { location: :country }, species: [])
  end

  def show
    @picture = Picture.find(params[:id])
    authorize @picture

    @related_species = related_species
    @related_categories = related_categories
  end

  private

  def picture_params
    params.require(:picture).permit(:photo)
  end

  def related_species
    @picture.species.each_with_object({}) do |species, result|
      result[species] = Picture
                        .joins(:species)
                        .where(species: { id: species.id })
                        .where.not(id: @picture.id)
                        .distinct
                        .limit(10)
    end
  end

  def related_categories
    result = {}

    categories = @picture.species.map(&:category).uniq

    categories.each do |category|
      pictures = Picture
                 .joins(:species)
                 .where(species: { category_id: category.id })
                 .where.not(id: @picture.id)
                 .distinct
                 .limit(10)

      result[category] = pictures
    end

    result
  end
end
