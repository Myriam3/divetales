class Category < ApplicationRecord
  has_many :species, dependent: :destroy

  validate :name, presence: true, length: { maximum: 150 }
  validate :classification, presence: true
  validate :description, length: { maximum: 500 }
end
