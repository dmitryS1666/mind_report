Rails.application.config.after_initialize do
  ActionController::Base.add_flash_types :success, :info, :warning, :error
end
