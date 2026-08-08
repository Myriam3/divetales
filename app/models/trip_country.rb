class TripCountry < ApplicationRecord
  belongs_to :trip
  belongs_to :country
end
