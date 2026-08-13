class Trip < ApplicationRecord
  belongs_to :user
  has_many :dives, dependent: :destroy
  has_many :pictures, through: :dives
  has_many :trip_countries, dependent: :destroy
  has_many :countries, through: :trip_countries

  validates :title, presence: true, uniqueness: true, length: { maximum: 150 }
  validates :info, length: { maximum: 500 }
  validates :start_date, :end_date, presence: true
  validates :end_date, comparison: { greater_than: :start_date }
end
