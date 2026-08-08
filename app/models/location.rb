class Location < ApplicationRecord
  belongs_to :country

  validate :name, presence: true, uniqueness: true, length: { maximum: 150 }
end
