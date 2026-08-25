class Dive < ApplicationRecord
  DIVE_TYPES = [
    "shore",
    "boat",
    "drift",
    "wreck",
    "cave",
    "wall",
    "deep",
    "night",
    "macro"
  ].freeze

  belongs_to :trip
  belongs_to :location
  has_one_attached :cover_photo
  has_many :pictures, dependent: :destroy
  has_many :species, through: :pictures
  has_many :identifications, dependent: :nullify

  validates :trip, :location, :date, presence: true
  validates :dive_number, uniqueness: true, numericality: { greater_than: 0 }, allow_nil: true
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
            comparison: { less_than: :gauge_pressure_start },
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

  def display_name_html(include_date: false, include_time: false)
    text = []
    text << "##{dive_number}" if dive_number.present?
    text << (dive_site_name || location&.name)
    if include_date && date.present?
      text << <<~HTML.html_safe
        <span>#{I18n.l(date, format: '%Y-%m-%d')}</span>
      HTML
    end
    if include_time && start_time.present?
      text << <<~HTML.html_safe
        <small>#{I18n.l(start_time, format: '%H:%M')}</small>
      HTML
    end

    text.join(" ").html_safe
  end

  private

  def depth_over_time_json
    return if depth_over_time.blank?

    data = JSON.parse(depth_over_time)

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
