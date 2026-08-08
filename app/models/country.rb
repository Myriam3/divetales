class Country < ApplicationRecord
  has_many :locations

  validate :name, presence: true, uniqueness: true, length: { maximum: 150 }
end
