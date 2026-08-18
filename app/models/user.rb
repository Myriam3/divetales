class User < ApplicationRecord
  has_many :trips, dependent: :destroy
  has_many :dives, through: :trips
  has_many :identifications, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
