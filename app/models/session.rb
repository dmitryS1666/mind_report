class Session < ApplicationRecord
  belongs_to :user
  has_many :analyses, dependent: :nullify

  validates :title, presence: true
end
