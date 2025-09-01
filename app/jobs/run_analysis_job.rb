class RunAnalysisJob < ApplicationJob
  queue_as :default

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    analysis.update!(status: :transcribing)

    transcript = AudioTranscriber.new(analysis).call
    analysis.update!(transcript:, status: :analyzing)

    result = ReportGenerator.new(analysis).call
    analysis.update!(
      report_text: result[:text],
      report_json: result[:json],
      status: :done
    )
  rescue => e
    analysis.update!(status: :failed, error_message: e.message) rescue nil
    raise
  end
end
