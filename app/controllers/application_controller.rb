class ApplicationController < ActionController::Base
  def after_sign_up_path_for(resource)
    # страница, где расскажем проверить почту
    root_path
  end

  def after_confirmation_path_for(resource_name, resource)
    # после клика по ссылке подтверждения
    root_path
  end
end
