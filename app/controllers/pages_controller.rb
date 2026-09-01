class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @ongoing_trip = current_user.trips.find_by(
      title: "Indonesia & Malaysia travel 2026"
    )
    latest_species_ids = PictureSpecy
                         .joins(picture: { dive: :trip })
                         .where(trips: { user_id: current_user.id })
                         .order(created_at: :desc)
                         .pluck(:species_id)
                         .uniq
                         .first(5)

    @latest_species = Species
                      .where(id: latest_species_ids)
                      .with_attached_default_photo
                      .includes(:pictures, dives: :location)
    @media_gallery = Dive.joins(:pictures).includes(pictures: { photo_attachment: :blob }).order(date: :desc).distinct.limit(10)
  end
end
