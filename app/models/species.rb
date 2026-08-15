class Species < ApplicationRecord
  TAGS = [
    "tropical",
    "pelagic",
    "reef",
    "seagrass",
    "macro",
    "nocturnal"
  ].freeze

  belongs_to :category
  has_many :picture_species, dependent: :destroy
  has_many :pictures, through: :picture_species
  has_one_attached :default_photo

  validates :name, presence: true, length: { maximum: 150 }
  validates :category, presence: true
  validates :description, length: { maximum: 500 }
  validates :scientific_name, uniqueness: true, length: { maximum: 150 }

  validates_each :tags do |record, attr, value|
    value.each do |tag|
      record.errors.add(attr, "Not a valid tag") unless TAGS.include?(tag)
    end
  end
end
