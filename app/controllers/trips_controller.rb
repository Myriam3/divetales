class TripsController < ApplicationController
  before_action :authenticate_user!

  def index
    @trips = policy_scope(Trip).order(start_date: :desc)
  end

  def show
    @trip = policy_scope(Trip).find(params[:id])
    authorize @trip
  end

  def new
    @trip = current_user.trips.new
    authorize @trip
  end

  def create
    @trip = current_user.trips.new(trip_params)
    authorize @trip

    if @trip.save
      redirect_to @trip, notice: "Trip created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @trip = policy_scope(Trip).find(params[:id])
    authorize @trip
  end

  def update
    @trip = policy_scope(Trip).find(params[:id])
    authorize @trip

    if @trip.update(trip_params)
      redirect_to @trip, notice: "Trip updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:title, :start_date, :end_date, :info, country_ids: [])
  end
end
