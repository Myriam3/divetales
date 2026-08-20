require "exifr/jpeg"
require "exifr/tiff"

class Picture < ApplicationRecord
  belongs_to :dive
  has_many :picture_species, dependent: :destroy
  has_many :species, through: :picture_species
  has_one_attached :photo
  validates :dive, presence: true

  after_save :extract_photo_metadata

  def species_default?
    species.any? { |s| s.default_photo.attached? && s.default_photo.blob_id == photo.blob_id }
  end

  private

  def extract_photo_metadata
    return unless photo.attached?
    return if photo.metadata["date_taken"].present?

    parser_class = case photo.blob.content_type
                   when "image/jpeg"
                     EXIFR::JPEG
                   when "image/tiff"
                     EXIFR::TIFF
                   end
    return unless parser_class

    photo.blob.open do |file|
      data = parser_class.new(file)

      new_metadata = {}
      date = data.date_time_original || data.date_time
      new_metadata["date_taken"] = date.strftime("%Y-%m-%d %H:%M:%S") if date
      new_metadata["camera_model"] = data.model if data.model
      if data.gps
        new_metadata["gps_latitude"] = data.gps.latitude
        new_metadata["gps_longitude"] = data.gps.longitude
      end

      photo.blob.update!(metadata: photo.blob.metadata.merge(new_metadata)) if new_metadata.any?
    end
  rescue EXIFR::MalformedJPEG, EXIFR::MalformedTIFF, StandardError
    nil
  end
end
