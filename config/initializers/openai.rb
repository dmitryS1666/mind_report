# OpenAI initializer
# Используем ENV для всех параметров подключения (см. .env.example).
# Поддержка: OPENAI_API_KEY, OPENAI_API_BASE, OPENAI_ORG_ID, OPENAI_PROJECT_ID, OPENAI_TIMEOUT,
# а также стандартные переменные прокси HTTPS_PROXY/HTTP_PROXY.
#
# Для локальной разработки без сети можно включить фейковый клиент: OPENAI_FAKE=1

if ENV["OPENAI_API_KEY"].present?
  client_opts = { api_key: ENV["OPENAI_API_KEY"] }

  if ENV["OPENAI_API_BASE"].present?
    client_opts[:uri_base] = ENV["OPENAI_API_BASE"]
    client_opts[:base_url] = ENV["OPENAI_API_BASE"]
  end

  client_opts[:organization_id] = ENV["OPENAI_ORG_ID"] if ENV["OPENAI_ORG_ID"].present?
  client_opts[:project]         = ENV["OPENAI_PROJECT_ID"] if ENV["OPENAI_PROJECT_ID"].present?

  timeout = ENV.fetch("OPENAI_TIMEOUT", "30").to_i
  client_opts[:request_timeout] = timeout if timeout > 0

  proxy_url = ENV["OPENAI_PROXY"].presence || ENV["HTTPS_PROXY"].presence || ENV["HTTP_PROXY"].presence
  if proxy_url.present?
    client_opts[:client_options] ||= {}
    client_opts[:client_options][:proxy] = proxy_url
  end

  begin
    OPENAI_CLIENT = OpenAI::Client.new(**client_opts)
    Rails.logger.info "[OpenAI] client initialized"
  rescue => e
    Rails.logger.error "[OpenAI] failed to initialize: #{e.message}. Retrying with api_key only."
    OPENAI_CLIENT = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  end

elsif ENV["OPENAI_FAKE"] == "1"
  # Простейший фейк для локальной разработки
  module OpenAiStub
    class AudioAPI
      def transcriptions; self; end
      def create(file:, model:); { "text" => "[FAKE TRANSCRIPT from #{File.basename(file)}]" }; end
    end
    class ResponsesAPI
      def create(model:, input:, temperature: nil, **_opts)
        { "output_text" => "Демо-ответ (FAKE) для модели #{model}" }
      end
    end
    class Client
      def audio; @audio ||= AudioAPI.new; end
      def responses; @responses ||= ResponsesAPI.new; end
    end
  end
  OPENAI_CLIENT = OpenAiStub::Client.new
  Rails.logger.warn "[OpenAI] FAKE mode enabled (ENV OPENAI_FAKE=1)"
else
  OPENAI_CLIENT = nil
  Rails.logger.warn "[OpenAI] disabled: no OPENAI_API_KEY and OPENAI_FAKE!=1"
end
