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
  validates :tank_type, presence: true
  validates :gauge_pressure_start, numericality: { greater_than_or_equal_to: 0 }
  validates :gauge_pressure_end, comparison: { greater_than: :gauge_pressure_start }
  validates :end_time, comparison: { greater_than: :start_time }

  enum :tank_type, {
    air: 1,
    nitrox: 2,
    trimix: 3,
    other: 4
  }

  validates_each :dive_types do |record, attr, value|
    value.each do |type|
      next if type.blank?

      record.errors.add(attr, "Not a valid type") unless DIVE_TYPES.include?(type)
    end
  end

  # TODO
  # depth_over_time -> JSON
end
