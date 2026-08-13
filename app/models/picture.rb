class Picture < ApplicationRecord
  belongs_to :dive
  has_many :picture_species, dependent: :destroy
  has_many :species, through: :picture_species

  validates :dive, presence: true
end
