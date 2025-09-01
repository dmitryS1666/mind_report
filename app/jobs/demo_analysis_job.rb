# frozen_string_literal: true

class DemoAnalysisJob < ApplicationJob
  queue_as :default

  STEPS  = ["Анализирую аудиофайл…", "Ищу закономерности…", "Подготавливаю ответ…", "Формирую отчёт…"].freeze
  STEP_MS = 1200

  def perform(analysis_id)
    analysis = Analysis.find_by(id: analysis_id)
    return unless analysis
    return unless analysis.queued? || analysis.processing?

    analysis.update!(status: :processing)
    broadcast_status(analysis)
    broadcast_step(analysis, "Старт обработки", kind: :info)

    STEPS.each_with_index do |step, idx|
      broadcast_step(analysis, "#{step} (#{percent(idx)}%)", kind: :progress)
      sleep STEP_MS / 1000.0
      analysis.reload
      break if analysis.failed?
    end

    # 1) транскрипт — заглушка
    transcript = "Тестовая транскрипция (демо)."

    # 2) берём короткий промт (free/short/ru), если нет — дефолты
    prompt = PromptTemplate
               .where(key: "sales_session",
                      plan: PromptTemplate.plans[:free],
                      report_kind: PromptTemplate.report_kinds[:short],
                      locale: I18n.locale)
               .order(version: :desc).first

    system_prompt = prompt&.system_prompt || "Ты — ассистент-аналитик продаж. Сделай краткий отчёт."
    user_prompt   = prompt&.user_prompt   || <<~TXT
      Дано: транскрипт разговора менеджера с клиентом.
      Задача: кратко ответить по 4 пунктам: Клиент, Менеджер, Итог, Рекомендации.
    TXT

    # 3) ответ «модели» через заглушку (принимает любые лишние kwargs)
    report_text = OpenAiStub.summarize(
      transcript: transcript,
      prompt_key: "demo_short_v1",
      plan: :free,
      report_kind: :short,
      prompt: prompt,
      system_prompt: system_prompt,
      user_prompt: user_prompt
    )

    # 4) сохранили результат и обновили карточку
    analysis.update!(
      status: :ready,
      transcript: transcript.truncate(10_000),
      report_text: report_text,
      report_kind: :short
    )
    broadcast_status(analysis)
    broadcast_done(analysis)

  rescue => e
    if analysis&.persisted?
      analysis.update_columns(status: Analysis.statuses[:failed],
                              error_message: e.message,
                              updated_at: Time.current)
      broadcast_status(analysis)
      broadcast_error(analysis, "Ошибка: #{e.message}")
    end
    raise
  end

  private

  def percent(idx)
    (((idx + 1).to_f / STEPS.size) * 100).round
  end

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

  def broadcast_status(analysis)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name(analysis.user_id),
      target: ActionView::RecordIdentifier.dom_id(analysis, :status),
      partial: "analyses/status",
      locals: { analysis: analysis }
    )
  end

  def broadcast_done(analysis)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name(analysis.user_id),
      target: ActionView::RecordIdentifier.dom_id(analysis, :panel),
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
