class TripsController < ApplicationController
  before_action :authenticate_user!

  def index
    @trips = policy_scope(Trip).order(start_date: :desc)
  end

  def show
    @trip = policy_scope(Trip).find(params[:id])
    @dives = @trip.dives.order(date: :desc)
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

  def update_cover_photo
    @trip = policy_scope(Trip).find(params[:id])
    authorize @trip, :update?

    if @trip.update(cover_photo_params)
      redirect_back fallback_location: trips_path, notice: "Trip photo updated!"
    else
      redirect_back fallback_location: trips_path, alert: "Photo could not be updated."
    end
  end

  def destroy
    @trip = policy_scope(Trip).find(params[:id])
    authorize @trip

    @trip.destroy
    redirect_to trips_path, notice: "Trip deleted."
  end

  private

  def trip_params
    params.require(:trip).permit(:title, :start_date, :end_date, :info, country_ids: [])
  end

  def cover_photo_params
    params.require(:trip).permit(:cover_photo)
  end
end
