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
    puts "USER: #{current_user.id}"
    puts "TRIP USER: #{@dive.trip.user.id}"
    puts "POLICY: #{DivePolicy.new(current_user, @dive).show?}"
    authorize @dive
  end

  def destroy
    @dive = Dive.find(params[:id])
    authorize @dive
  end
end
