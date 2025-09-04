class Analysis < ApplicationRecord
  belongs_to :user
  belongs_to :session, optional: true

  enum status: { queued: 0, processing: 1, ready: 2, failed: 3 }, _default: :queued
  enum report_kind: { short: 0, full: 1 }

  has_one_attached :audio
  has_one_attached :text_file

  validate :audio_presence_type_size, if: :require_audio_validation?
  validate :audio_or_transcript_present

  private
  def require_audio_validation?
    # требуем проверять тип/размер только если аудио вообще есть И это нужно
    audio.attached? && (Rails.env.production? || report_kind == "full")
  end

  def audio_or_transcript_present
    if !audio.attached? && transcript.blank?
      errors.add(:base, "Нужно загрузить аудио или текст")
    end
  end

  def audio_presence_type_size
    unless audio.attached?
      errors.add(:audio, "не загружен")
      return
    end

    acceptable = %w[
      audio/mpeg audio/mp3 audio/mp4 audio/x-m4a audio/m4a
      audio/aac  audio/wav audio/ogg audio/webm audio/x-wav audio/mpeg3
    ]
    errors.add(:audio, "недопустимый формат") unless acceptable.include?(audio.content_type)
    errors.add(:audio, "слишком большой файл (до 100 МБ)") if audio.blob.byte_size > 100.megabytes
  end

  def audio_presence_type_size
    unless audio.attached?
      errors.add(:audio, "не загружен")
      return
    end

    acceptable = %w[
      audio/mpeg audio/mp3 audio/mp4 audio/x-m4a
      audio/aac  audio/wav audio/ogg audio/webm
      audio/x-wav audio/mpeg3
    ]
    unless acceptable.include?(audio.content_type)
      errors.add(:audio, "недопустимый формат")
    end

    if audio.blob.byte_size > 100.megabytes
      errors.add(:audio, "слишком большой файл (до 100 МБ)")
    end
  end
end
