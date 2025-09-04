Rails.application.configure do
  if Rails.env.production?
    ActiveJob::Base.queue_adapter = :sidekiq
  
    redis_url = ENV.fetch("REDIS_URL") { "redis://127.0.0.1:6379/0" }

    Sidekiq.configure_server { |c| c.redis = { url: redis_url } }
    Sidekiq.configure_client { |c| c.redis = { url: redis_url } }
  end
end