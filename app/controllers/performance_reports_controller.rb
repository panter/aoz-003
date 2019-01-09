class PerformanceReportsController < ApplicationController
  before_action :set_performance_report, only: [:show, :edit, :update, :destroy]

  def index
    authorize PerformanceReport
    @q = PerformanceReport.all.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @performance_reports = @q.result
  end

  def show
    @value_orders = value_display_orders
  end

  def new
    @performance_report = PerformanceReport.new
    authorize @performance_report
  end

  def edit; end

  def create
    @performance_report = PerformanceReport.new report_params
    @performance_report.user = current_user
    authorize @performance_report
    if @performance_report.save
      redirect_to @performance_report, make_notice
    else
      render :new
    end
  end

  def update
    if @performance_report.update(report_params)
      redirect_to @performance_report, make_notice
    else
      render :edit
    end
  end

  def destroy
    @performance_report.destroy
    redirect_to performance_reports_path, make_notice
  end

  private

  def set_performance_report
    @performance_report = PerformanceReport.find(params[:id])
    @report_content = @performance_report.report_content
    authorize @performance_report
  end

  def report_params
    params.require(:performance_report).permit(:period_start, :period_end, :users_id,
      :report_content, :comment, :title, :scope, :extern)
  end

  def value_display_orders
    @value_display_orders ||= {
      volunteers: [
        :created, :inactive, :resigned, [:total, :active],
        :active_assignment, :active_group_assignment, :only_assignment_active, :only_group_active, :active_both, [:active_total, :active],
        :assignment_hour_records, :assignment_hours, :group_offer_hour_records, :group_offer_hours, [:total_hours, :active],
        :assignment_feedbacks, :group_offer_feedbacks, [:total_feedbacks, :active],
        :assignment_trial_feedbacks, :group_offer_trial_feedbacks, [:total_trial_feedbacks, :active]
      ] + Event.kinds.keys.map(&:to_sym) + [[:total_events, :active]],
      clients: [:created, :inactive, :resigned, :active_assignment, [:total, :active]],
      assignments: [:created, :started, :active, :ended, :first_instruction_lessons, [:all, :active]],
      group_offers_first: [:created, :created_assignments, :ended, [:all, :active],
                           [:feedback_count, :active]],
      group_offers_second: [:total_created_assignments, :total_started_assignments,
                            :total_active_assignments, :total_ended_assignments,
                            [:total_assignments, :active]]
    }
  end
end
