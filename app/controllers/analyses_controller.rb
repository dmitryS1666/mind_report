class AnalysesController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.period_reset_if_needed!
    unless current_user.in_quota?
      redirect_to dashboard_path, alert: "Лимит анализов исчерпан" and return
    end

    @analysis = current_user.analyses.new(analysis_params)
    @analysis.report_kind = :short unless current_user.can_request_full_report?
    @analysis.openai_model ||= 'gpt-5'

    if @analysis.save
      current_user.consume_quota!
      RunAnalysisJob.perform_later(@analysis.id)
      redirect_to dashboard_path(anchor: "analysis-#{@analysis.id}"), notice: "Анализ запущен"
    else
      redirect_to dashboard_path, alert: @analysis.errors.full_messages.to_sentence
    end
  end

  # POST /analyses/demo
  # Принимает аудиофайл, создаёт Analysis и запускает демо-обработку (без OpenAI).
  def demo
    @analysis = current_user.analyses.new(
      status: :queued,
      report_kind: :short,
      openai_model: "stub:v1"
    )

    # поддержим оба варианта формы: analysis[audio] и просто audio
    uploaded = params.dig(:analysis, :audio) || params[:audio]
    @analysis.audio.attach(uploaded) if uploaded.present?

    @analysis.save! # валидируем уже с прикреплённым файлом

    DemoAnalysisJob.perform_later(@analysis.id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to authenticated_root_path, notice: "Анализ запущен" }
    end
  end

  def clear_history
    current_user.analyses.delete_all
    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "История очищена"
        render turbo_stream: [
          # перерисовать список в панели истории
          turbo_stream.update("history_list", partial: "dashboard/history_list", locals: { analyses: [] }),
          # и показать тост
          turbo_stream.append("toasts", partial: "shared/toast", locals: { kind: :success, message: "История очищена" })
        ]
      end
      format.html { redirect_to dashboard_path, notice: "История очищена" }
    end
  end

  def show
    @analysis = current_user.analyses.find(params[:id])
  end

  private

  def analysis_params
    params.require(:analysis).permit(:report_kind, :audio)
  end
end
