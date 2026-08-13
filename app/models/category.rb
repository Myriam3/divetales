class Category < ApplicationRecord
  has_many :species, dependent: :destroy

  validates :name, presence: true, length: { maximum: 150 }
  validates :classification, presence: true
  validates :description, length: { maximum: 500 }

  enum :classification, {
    other: 0,
    fish: 1,
    mammal: 2,
    reptile: 3,
    crustacean: 4,
    mollusk: 5,
    cnidarian: 6,
    echinoderm: 7,
    annelid: 8,
    sponge: 9
  }
end
