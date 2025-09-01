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
    @analysis = current_user.analyses.create!(
      status: :queued,
      report_kind: :short,    # укороченная версия для демо
      openai_model: "stub:v1" # помечаем, что это заглушка
    )

    # сохраняем прикреплённый файл (если используешь ActiveStorage — раскомментируй)
    # @analysis.audio.attach(params[:analysis][:audio]) if params.dig(:analysis, :audio).present?

    DemoAnalysisJob.perform_later(@analysis.id)

    respond_to do |format|
      format.turbo_stream # рендерим turbo_stream ответ (см. views/analyses/demo.turbo_stream.erb)
      format.html { redirect_to authenticated_root_path, notice: "Анализ запущен" }
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
