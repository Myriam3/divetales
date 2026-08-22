class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @latest_species = Species.with_attached_default_photo.includes(:pictures,
                                                                   dives: :location).order(created_at: :desc).limit(5)
    @media_gallery = Dive.joins(:pictures).includes(pictures: { photo_attachment: :blob }).order(date: :desc).distinct.limit(10)
  end
end
