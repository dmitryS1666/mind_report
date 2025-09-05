class FooterSection < ApplicationRecord
  has_many :footer_links, -> { published.order(:position) }, dependent: :destroy
  scope :published, -> { where(published: true).order(:position) }

  validates :title, presence: true
end
