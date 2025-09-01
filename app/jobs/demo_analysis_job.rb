class DemoAnalysisJob < ApplicationJob
  queue_as :default

  # пошагово транслируем статусы через Turbo Streams
  STEPS = [
    "Анализирую аудиофайл…",
    "Ищу закономерности…",
    "Подготавливаю ответ…",
    "Формирую отчёт…"
  ]

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)

    analysis.update!(status: :processing)
    broadcast_step(analysis, "Старт обработки", kind: :info)

    STEPS.each do |step|
      broadcast_step(analysis, step, kind: :progress)
      sleep 1.2 # имитация работы
    end

    # Заглушка транскриба — обычно это было бы через Whisper/ASR
    transcript = "Тестовая транскрипция (демо)."

    # Получаем «ответ модели» через заглушку
    report_text = OpenAIStub.summarize(
      transcript: transcript,
      prompt_key: "demo_short_v1"
    )

    analysis.update!(
      status: :ready,
      transcript: transcript,
      report_text: report_text,
      report_kind: :short
    )

    broadcast_done(analysis)
  rescue => e
    analysis.update!(status: :failed, error_message: e.message)
    broadcast_error(analysis, "Ошибка: #{e.message}")
    raise
  end

  private

  def stream_name(user_id)
    "analyses_stream_user_#{user_id}"
  end

  def broadcast_step(analysis, message, kind: :info)
    Turbo::StreamsChannel.broadcast_append_to(
      stream_name(analysis.user_id),
      target: "analysis_stream_target",
      partial: "analyses/stream_message",
      locals: { analysis: analysis, message: message, kind: kind }
    )
  end

  def broadcast_done(analysis)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name(analysis.user_id),
      target: dom_id(analysis, :panel),
      partial: "analyses/panel",
      locals: { analysis: analysis }
    )
  end

  def broadcast_error(analysis, message)
    Turbo::StreamsChannel.broadcast_append_to(
      stream_name(analysis.user_id),
      target: "analysis_stream_target",
      partial: "analyses/stream_message",
      locals: { analysis: analysis, message: message, kind: :error }
    )
  end
end
