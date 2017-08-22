class PerformanceReportsController < ApplicationController
  include MakeNotice

  before_action :set_performance_report, only: [:show, :edit, :update, :destroy]

  def index
    @performance_reports = PerformanceReport.all
    authorize PerformanceReport
  end

  def show; end

  def new
    @performance_report = PerformanceReport.new
    authorize @performance_report
  end

  def edit; end

  def create
    @performance_report = PerformanceReport.new(report_params.merge(convert_start_end))
    @performance_report.user = current_user
    authorize @performance_report
    if @performance_report.save
      redirect_to(@performance_report, make_notice)
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

  def convert_start_end
    dates = report_params.slice(:period_start, :period_end)
                         .transform_values(&:to_datetime)
    dates[:period_start] = dates[:period_start].at_beginning_of_day
    dates[:period_end] = dates[:period_end].at_end_of_day
    dates
  end

  def set_performance_report
    @performance_report = PerformanceReport.find(params[:id])
    authorize @performance_report
  end

  def report_params
    params.require(:performance_report).permit(:period_start, :period_end, :users_id,
      :report_content, :comment, :title, :scope, :extern)
  end
end
