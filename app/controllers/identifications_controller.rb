require "open-uri"

class IdentificationsController < ApplicationController
  before_action :set_dive, only: %i[index create confirm]
  before_action :set_identification, only: %i[details confirm save retry]
  before_action :set_species_params, only: %i[details confirm save]

  def index
    identification = Identification.new
    authorize identification, :create?

    if params[:identification_id].present?
      @identification = current_user.identifications.find(
        params[:identification_id]
      )
      authorize @identification, :show?

      @results = Array(@identification.results).map(&:deep_symbolize_keys)
    else
      @identification = nil
      @results = []
    end
  end

  def create
    if no_input_provided?
      flash.now[:alert] = "Please provide a description or upload an image."
      render :index, status: :unprocessable_entity
      return
    end

    @identification = current_user.identifications.build(
      dive: @dive,
      user_prompt: build_user_prompt,
      status: :pending
    )

    authorize @identification

    attach_image_if_present

    @identification.save!

    IdentificationJob.perform_later(@identification.id)

    redirect_to identification_path(
      identification_id: @identification.id,
      dive_id: @dive&.id
    )
  end

  def details
    @result = find_result_by_scientific_name

    if @result.blank?
      redirect_to identification_path(
        identification_id: @identification.id
      ), alert: "Unable to find this species in the identification results."
      return
    end

    @species = Species.find_by(scientific_name: @scientific_name)

    @details = @species&.details || fetch_or_generate_identification_details
  end

  def confirm
    @default_photo_url = params[:default_photo_url]

    # @species = Species.find_by(
    #   scientific_name: @scientific_name
    # )

    @trip = current_user.trips.find_by(id: params[:trip_id])

    if @trip
      @dives = @trip.dives.order(date: :desc)
      if @dive.present?
        index = @dives.index(@dive)
        @dive_number = @dives.length - index if index
      end
    else
      @trips = current_user.trips.order(created_at: :desc)
    end
  end

  def save
    dive_id = params[:dive_id]

    if dive_id.blank?
      redirect_to identification_path,
                  alert: "Please choose a dive first."
      return
    end

    @dive = current_user.dives.find(dive_id)

    result = find_result_by_scientific_name

    unless result
      redirect_to identification_path(
        identification_id: @identification.id
      ), alert: "Unable to find the selected species."
      return
    end

    @species = ConfirmIdentificationService.call(
      user: current_user,
      identification: @identification,
      dive: @dive,
      result: result,
      common_name: @common_name,
      default_photo_url: params[:default_photo_url]
    )

    redirect_to dive_path(@dive), notice: "Successfully added #{@species.name} to your dive!"
  end

  def retry
    @identification.update!(status: :pending)

    IdentificationJob.perform_later(@identification.id)

    redirect_to identification_path(
      identification_id: @identification.id,
      dive_id: @identification.dive_id
    )
  end

  private

  def set_dive
    @dive = current_user.dives.find_by(id: params[:dive_id]) if params[:dive_id].present?
  end

  def set_identification
    @identification = current_user.identifications.find(params[:identification_id])
    authorize @identification, :"#{action_name}?"
  end

  def set_species_params
    @scientific_name = params[:scientific_name].to_s.strip
    @common_name = params[:common_name].to_s.strip
  end

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

  def uploaded_image
    identification_params[:upload] || identification_params[:camera]
  end

  def observation_params
    identification_params.slice(
      :color,
      :size,
      :shape,
      :behavior
    ).compact_blank
  end

  def dive_context_params
    identification_params.slice(
      :location,
      :dive_site,
      :date,
      :depth,
      :habitat
    ).compact_blank
  end

  def no_input_provided?
    uploaded_image.blank? && observation_params.blank? && dive_context_params.blank? && identification_params[:additional_info].blank?
  end

  def build_user_prompt
    SpeciesIdUserPrompt.call(
      observation: observation_params,
      dive_context: dive_context_params,
      additional_info: identification_params[:additional_info]
    )
  end

  def attach_image_if_present
    return if uploaded_image.blank?

    uploaded_image.tempfile.rewind
    @identification.image.attach(
      io: uploaded_image.tempfile,
      filename: uploaded_image.original_filename,
      content_type: uploaded_image.content_type
    )
  end

  def find_result_by_scientific_name
    @identification.results.find do |result|
      result["scientific_name"].to_s.strip == @scientific_name
    end
  end

  def fetch_or_generate_identification_details
    details = @identification.details || {}

    unless details[@scientific_name].present?
      # preventing the app from accidentally queuing up multiple identical AI jobs
      details[@scientific_name] = { "status" => "pending" }
      @identification.update!(details: details)
      SpeciesDetailsJob.perform_later(@identification.id, @scientific_name)
    end

    details[@scientific_name]
  end
end
