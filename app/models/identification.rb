class Identification < ApplicationRecord
  belongs_to :user
  belongs_to :dive, optional: true
  belongs_to :species, optional: true

  has_one_attached :image

  enum :status, {
    pending: "pending",
    confirmed: "confirmed"
  }
end
