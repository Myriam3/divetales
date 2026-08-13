class Country < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :trip_countries, dependent: :destroy
  has_many :countries, through: :trip_countries

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
end
