# В dev/test можно запускать без ключа. 
# Если ключ есть — используем реальный клиент, иначе — nil или фейк.
if ENV["OPENAI_API_KEY"].present?
  OpenAI_CLIENT = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  Rails.logger.info "[OpenAI] client initialized"
elsif ENV["OPENAI_FAKE"] == "1"
  # Простейший фейк для локальной разработки
  module OpenAIStub
    class AudioAPI
      def transcriptions
        self
      end
      def create(file:, model:)
        { "text" => "[FAKE TRANSCRIPT from #{File.basename(file)}]" }
      end
    end
    class ResponsesAPI
      def create(model:, input:, response_format: nil)
        # имитируем структуру .responses.create, возвращая поле output_text
        { "output_text" => "[FAKE REPORT for model=#{model}] \n\n" \
                           "— Тема 1\n— Тема 2\n— Действия: 1) Сделать X 2) Сделать Y" }
      end
    end
    class Client
      def audio; @audio ||= AudioAPI.new; end
      def responses; @responses ||= ResponsesAPI.new; end
    end
  end
  OpenAI_CLIENT = OpenAIStub::Client.new
  Rails.logger.warn "[OpenAI] FAKE mode enabled (ENV OPENAI_FAKE=1)"
else
  OpenAI_CLIENT = nil
  Rails.logger.warn "[OpenAI] disabled: no OPENAI_API_KEY and OPENAI_FAKE!=1"
end
