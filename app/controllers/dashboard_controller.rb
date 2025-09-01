class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @history_analyses = current_user.analyses.order(created_at: :desc).limit(50)
    @recent_analyses  = @history_analyses.first(10)
  end
end
