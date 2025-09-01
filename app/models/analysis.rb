class Analysis < ApplicationRecord
  belongs_to :user
  belongs_to :session, optional: true

  enum status: {
    queued: 0,
    processing: 1,
    ready: 2,
    failed: 3
  }, _default: :queued

  enum report_kind: { short: 0, full: 1 }

  has_one_attached :audio

  validates :report_kind, presence: true
  validate  :audio_presence_type_size

  MAX_AUDIO_SIZE_MB = 50
  ALLOWED_AUDIO = %w[
    audio/mpeg audio/mp3 audio/wav audio/x-wav audio/m4a audio/aac audio/ogg audio/webm
  ].freeze

  scope :recent, -> { order(created_at: :desc) }

  def display_title
    "#{report_kind.capitalize} — #{created_at.strftime('%d.%m.%Y %H:%M')}"
  end

  private

  def audio_presence_type_size
    unless audio.attached?
      errors.add(:audio, "не загружен")
      return
    end
    unless ALLOWED_AUDIO.include?(audio.blob.content_type)
      errors.add(:audio, "недопустимый формат (mp3/wav/m4a/ogg/webm)")
    end
    if audio.blob.byte_size > MAX_AUDIO_SIZE_MB.megabytes
      errors.add(:audio, "слишком большой (до #{MAX_AUDIO_SIZE_MB} МБ)")
    end
  end
end
