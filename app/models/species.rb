class Species < ApplicationRecord
  belongs_to :category
  has_many :picture_species
  has_many :pictures, through: :picture_species

  validate :name, presence: true, length: { maximum: 150 }
  validate :category, presence: true
  validate :description, length: { maximum: 500 }
  validate :scientific_name, uniqueness: true, length: { maximum: 150 }
end
