class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @analysis = Analysis.new
    @recent_analyses = current_user.analyses.order(created_at: :desc).limit(10)
  end
end
