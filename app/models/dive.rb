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
  validates :gauge_pressure_start, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :end_time, comparison: { greater_than: :start_time }, allow_blank: true

  enum :tank_type, {
    air: 1,
    nitrox: 2,
    trimix: 3,
    other: 4
  }

  validates :gauge_pressure_end,
            comparison: { greater_than: :gauge_pressure_start },
            if: -> { gauge_pressure_start.present? && gauge_pressure_end.present? },
            allow_blank: true

  validates :end_time,
            comparison: { greater_than: :start_time },
            if: -> { start_time.present? && end_time? },
            allow_blank: true

  validates_each :dive_types do |record, attr, value|
    value.each do |type|
      next if type.blank?

      record.errors.add(attr, "Not a valid type") unless DIVE_TYPES.include?(type)
    end
  end

  validate :depth_over_time_json

  private

  def depth_over_time_json
    return if depth_over_time.blank?

    data = JSON.parse(depth_over_time)
    puts "TEST #{data}"

    unless data.is_a?(Array)
      errors.add(:depth_over_time, "must be a valid JSON")
      return
    end

    data.each_with_index do |entry, index|
      unless entry.is_a?(Hash)
        errors.add(:depth_over_time, "#{index} must be an object")
        next
      end

      if entry["timestamp"].present?
        begin
          Time.iso8601(entry["timestamp"].to_s)
        rescue ArgumentError
          errors.add(:depth_over_time, "timestamp is invalid (#{index})")
        end
      else
        errors.add(:depth_over_time, "timestamp not found (#{index})")
      end

      errors.add(:depth_over_time, "depth must be a number (#{index})") unless entry["depth"].is_a?(Numeric)
    end
  rescue JSON::ParserError, TypeError
    errors.add(:depth_over_time, "must be a valid JSON")
  end
end
