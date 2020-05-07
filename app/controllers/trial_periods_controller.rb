class TrialPeriodsController < ApplicationController
  def index
    authorize TrialPeriod
    @q = TrialPeriod.includes(:trial_period_mission).ransack(params[:q])
    @q.sorts = ['end_date asc'] if @q.sorts.empty?
    @trial_periods = @q.result.paginate(page: params[:page])
  end

  def update
    @trial_period = TrialPeriod.find(params[:id])
    authorize @trial_period
    @trial_period.verify!(current_user)
    redirect_to trial_periods_path(q: params.to_unsafe_hash[:q])
  end
end
