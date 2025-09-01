class PromptTemplate < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Рендерим пользовательский промпт: {{TRANSCRIPT}} → фактический текст транскрипта
  def render_user_prompt(transcript:)
    (user_prompt || "").gsub('{{TRANSCRIPT}}', transcript.to_s)
  end
end
