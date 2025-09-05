class SiteSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.[](key)
    find_by(key: key)&.value
  end

  def self.fetch(key, default = nil)
    find_or_create_by!(key: key) { |r| r.value = default }.value
  end

  def self.set(key, value)
    rec = find_or_initialize_by(key: key)
    rec.value = value
    rec.save!
    rec
  end
end
