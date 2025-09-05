class FooterLink < ApplicationRecord
  belongs_to :footer_section
  scope :published, -> { where(published: true).order(:position) }

  validates :label, :url, presence: true
end
