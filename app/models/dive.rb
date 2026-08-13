class Dive < ApplicationRecord
  belongs_to :trip
  belongs_to :location
  has_many :pictures, dependent: :destroy
  has_many :species, through: :pictures

  validates :trip, :location, :dive_types, presence: true
  validates :dive_site_name, presence: true, length: { maximum: 150 }
  validates :note, length: { maximum: 500 }

  # TODO
  # depth_over_time -> JSON
  # type -> enum
end
