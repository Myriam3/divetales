class Location < ApplicationRecord
  belongs_to :country
  has_many :dives
  has_many :dive_sites

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
end
