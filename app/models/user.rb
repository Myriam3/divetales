class User < ApplicationRecord
  has_many :trips, dependent: :destroy
  has_many :dives, through: :trips

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
