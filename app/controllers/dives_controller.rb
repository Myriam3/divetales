class DivesController < ApplicationController
  def index
    @dives = policy_scope(Dive).order(:date)
  end

  def new
    @dive = Dive.new
    authorize @dive
  end

  def create
    @dive = Dive.new
    authorize @dive
  end

  def show
    @dive = Dive.find(params[:id])
    @species = @dive.pictures
                    .includes(:species)
                    .flat_map(&:species)
                    .uniq
    authorize @dive
  end

  def destroy
    @dive = Dive.find(params[:id])
    authorize @dive
  end
end
