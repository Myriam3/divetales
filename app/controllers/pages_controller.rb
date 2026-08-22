class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @latest_species = Species.includes(dive: :location).order(created_at: :desc).limit(5)
    @dives_with_media = Dive.joins(:photos_attachments).order(date: :desc).limit(10)
  end
end
