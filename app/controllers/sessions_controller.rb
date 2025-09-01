class SessionsController < ApplicationController
  before_action :authenticate_user!
  def create
    s = current_user.sessions.create!(title: params[:title].presence || "Диалог #{Time.current.strftime('%d.%m %H:%M')}")
    redirect_to dashboard_path(session_id: s.id)
  end
end
