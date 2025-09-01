class ReportGenerator
  def initialize(analysis)
    @analysis = analysis
  end

  def call
    prompt = PromptTemplate.find_by!(key: key_for(@analysis))
    sys = prompt.system_prompt.to_s
    usr = prompt.render_user_prompt(transcript: @analysis.transcript)

    resp = OPENAI_CLIENT.responses.create(
      model: @analysis.openai_model,  # по умолчанию 'gpt-5' из миграции
      input: [
        { role: :system, content: sys },
        { role: :user,   content: usr }
      ]
    )

    { text: extract_text(resp), json: nil }
  end

  private

  def key_for(analysis)
    analysis.full? ? 'full_report' : 'short_report'
  end

  # извлекаем текст из ответа Responses API
  def extract_text(resp)
    # SDK может возвращать разные ключи в зависимости от версии; самый простой:
    resp.dig("output_text") || resp.to_s
  end
end
