class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def test
    @trips = Trip.includes(
      :user,
      :countries,
      dives: [
        :location,
        { pictures: [:species, { image_attachment: :blob }] }
      ]
    ).order(start_date: :desc)
  end
end
