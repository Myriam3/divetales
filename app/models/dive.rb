class Dive < ApplicationRecord
  DIVE_TYPES = [
    "shore",
    "boat",
    "drift",
    "wreck",
    "cave",
    "wall",
    "deep",
    "night"
  ].freeze

  belongs_to :trip
  belongs_to :location
  has_many :pictures, dependent: :destroy
  has_many :species, through: :pictures
  has_many :identifications, dependent: :nullify

  validates :trip, :location, :date, presence: true
  validates :dive_site_name, presence: true, length: { maximum: 150 }
  validates :note, length: { maximum: 500 }

  validates_each :dive_types do |record, attr, value|
    value.each do |type|
      next if type.blank?

      record.errors.add(attr, "Not a valid type") unless DIVE_TYPES.include?(type)
    end
  end

  # TODO
  # depth_over_time -> JSON
end
