Rails.application.configure do
  if Rails.env.production?
    ActiveJob::Base.queue_adapter = :sidekiq
  end
end