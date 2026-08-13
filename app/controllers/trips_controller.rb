class TripsController < ApplicationController
  before_action :authenticate_user!

  def index
    @trips = policy_scope(Trip).order(start_date: :desc)
  end

  def show
    @trip = policy_scope(Trip).find(params[:id])
    authorize @trip
  end
end
