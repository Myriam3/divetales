class Location < ApplicationRecord
  belongs_to :country

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
end
