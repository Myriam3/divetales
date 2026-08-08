class Trip < ApplicationRecord
  belongs_to :user
  has_many :dives
  has_many :pictures, through: :dives
  has_many :trip_countries
  has_many :countries, through: :trip_countries

  validate :title, presence: true, uniqueness: true, length: { maximum: 150 }
  validate :info, length: { maximum: 500 }
  validates :start_date, :end_date, presence: true
  validates :end_date, comparison: { greater_than: :start_date }
end
