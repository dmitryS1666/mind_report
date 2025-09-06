class AnalysesController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.period_reset_if_needed!
    unless current_user.in_quota?
      redirect_to dashboard_path, alert: "Лимит анализов исчерпан" and return
    end

    @analysis = current_user.analyses.new(analysis_params)
    @analysis.report_kind = :short unless current_user.can_request_full_report?
    @analysis.openai_model ||= ENV.fetch('OPENAI_MODEL', 'gpt-5')

    if @analysis.save
      current_user.consume_quota!
      RunAnalysisJob.perform_later(@analysis.id)
      redirect_to dashboard_path(anchor: "analysis-#{@analysis.id}"), notice: "Анализ запущен"
    else
      redirect_to dashboard_path, alert: @analysis.errors.full_messages.to_sentence
    end
  end

  def demo
    @analysis = current_user.analyses.new(
      status: :queued,
      report_kind: :short,
      openai_model: "stub:v1"
    )

    # принимаем либо analysis[file], либо file
    uploaded = params.dig(:analysis, :file) || params[:file]

    if uploaded.present?
      ct = uploaded.content_type.to_s

      if ct.start_with?("audio/")
        # оставляем как было — прикрепляем к audio
        @analysis.audio.attach(uploaded)
      else
        # считаем как текст (txt/md) — читаем содержимое и кладём сразу в transcript
        # (при желании можно также хранить файл во вложении)
        raw = uploaded.read.to_s.force_encoding("UTF-8")
        @analysis.transcript = raw.truncate(10_000)
        # опционально: если хотите хранить исходник:
        # @analysis.text_file.attach(uploaded)
      end
    end

    @analysis.save!

    DemoAnalysisJob.perform_later(@analysis.id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path, notice: "Анализ запущен" }
    end
  end

  def clear_history
    current_user.analyses.delete_all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("history_list", partial: "dashboard/history_list", locals: { analyses: [] }),
          turbo_stream.append("toast-root", partial: "shared/toasts", locals: { kind: "success", message: "История очищена" })
        ]
      end
      format.html { redirect_to dashboard_path, notice: "История очищена" }
    end
  end

  # Только HTML, без respond_to — никаких turbo-stream тут.
  def show
    @analysis = current_user.analyses.find(params[:id])
    # рендерит app/views/analyses/show.html.erb
  end

  # Отдельный экшен на скачивание
  def download
    analysis = current_user.analyses.find(params[:id])
    send_data analysis.report_text.to_s,
              filename: "analysis-#{analysis.id}.txt",
              type: "text/plain",
              disposition: "attachment"
  end

  def download_pdf
    analysis = current_user.analyses.find(params[:id])
    pdf = AnalysisReportPdf.new(analysis).render
    send_data pdf,
              filename: "analysis-#{analysis.id}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  private

  def analysis_params
    params.require(:analysis).permit(:report_kind, :audio)
  end
end
