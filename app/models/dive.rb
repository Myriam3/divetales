class Dive < ApplicationRecord
  belongs_to :trip
  belongs_to :location
  has_many :pictures, dependent: :destroy
  has_many :species, through: :pictures

  validates :trip, :location, :type, :date, presence: true
  validates :dive_site_name, presence: true, limit: { maximum: 150 }
  validates :note, limit: { maximum: 500 }

  # TODO
  # depth_over_time -> JSON
  # type -> enum
end
