# frozen_string_literal: true

# Простая заглушка "модели" OpenAI для dev/demo.
# Возвращает псевдо-отчёт на основе транскрипта и (опц.) шаблона.
class OpenAiStub
  # Принимаем **kwargs, чтобы не падать от лишних ключей (system_prompt, user_prompt и т.п.)
  def self.summarize(transcript:, prompt_key:, plan: :free, report_kind: :short, prompt: nil, **_extra)
    tips = [
      "Говорите короче, используйте паузы.",
      "Чаще подтверждайте ценность и выгоды.",
      "Больше открытых вопросов.",
      "Подводите итоги перед завершением.",
      "Используйте конкретные цифры и кейсы."
    ]
    findings = [
      "клиент сомневается в сроках",
      "важна гарантия результата",
      "не хватает конкретики в цене",
      "плохо прояснены следующие шаги"
    ]

    prompt_title = prompt&.version ? "#{prompt.key} v#{prompt.version}" : prompt_key.to_s

    <<~TEXT.strip
      🧠 Отчёт (#{report_kind}, шаблон: #{prompt_title}, режим: #{plan})

      1) Краткая выжимка:
      — Из разговора: «#{transcript.to_s.truncate(120)}»
      — Ключевая находка: #{findings.sample}

      2) Рекомендации (top-3):
      — #{tips.sample}
      — #{(tips - [tips.first]).sample}
      — #{(tips - [tips.first, tips[1]]).sample}

      3) Следующие шаги:
      — Уточнить сроки и контрольные точки.
      — Согласовать критерии успеха.
      — Запланировать повторный созвон.
    TEXT
  end
end
