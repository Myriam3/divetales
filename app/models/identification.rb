class Identification < ApplicationRecord
  attr_accessor :upload, :camera, :color, :size, :shape, :behavior,
                :location, :dive_site, :date, :depth, :habitat, :additional_info

  belongs_to :user
  belongs_to :dive, optional: true
  belongs_to :species, optional: true

  has_one_attached :image

  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed"
  }
end
