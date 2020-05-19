class TrialPeriodsController < ApplicationController
  before_action :set_trial_period, only: %i[update verify]

  def index
    authorize TrialPeriod
    @q = TrialPeriod.includes(:trial_period_mission).ransack(params[:q])
    @q.sorts = ['end_date asc'] if @q.sorts.empty?
    @trial_periods = @q.result.paginate(page: params[:page])
  end

  def update
    @trial_period.update!(trial_period_params)
    redirect_to redirect_with_q_path
  end

  def verify
    @trial_period.verify!(current_user)
    redirect_to redirect_with_q_path
  end

  private

  def redirect_with_q_path
    trial_periods_path(q: params.to_unsafe_hash[:q])
  end

  def trial_period_params
    params.require(:trial_period).permit(:notes)
  end

  def set_trial_period
    @trial_period = TrialPeriod.find(params[:id])
    authorize @trial_period
  end
end
