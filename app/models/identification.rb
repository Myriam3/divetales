class Identification < ApplicationRecord
  store :form_inputs,
        accessors: %i[color size shape behavior location dive_site date depth habitat additional_info],
        coder: JSON

  belongs_to :user
  belongs_to :dive, optional: true
  belongs_to :species, optional: true

  has_one_attached :image

  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed"
  }
end
