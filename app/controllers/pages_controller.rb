class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
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
