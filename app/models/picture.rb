class Picture < ApplicationRecord
  belongs_to :dive
  has_many :picture_species, dependent: :destroy
  has_many :species, through: :picture_species
  has_one_attached :photo
  validates :dive, presence: true
  after_save :extract_photo_metadata

  private

  def extract_photo_metadata
    photos.each do |photo|
      next if photo.metadata["date_taken"].present? # already processed

      photo.blob.open do |file|
        data = Exif::Data.new(file)
        date_taken = data.date_time_original # e.g. "2026:08:13 14:32:10"
        photo.blob.update!(metadata: photo.blob.metadata.merge("date_taken" => date_taken)) if date_taken
      end
    rescue Exif::NotReadable
      next # incase some images don't have EXIF (e.g. screenshots, some PNGs)
    end
  end
end
