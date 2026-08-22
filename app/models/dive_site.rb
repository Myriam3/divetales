class DiveSite < ApplicationRecord
  belongs_to :location, optional: true
end
