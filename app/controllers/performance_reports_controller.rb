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
    @performance_report = PerformanceReport.new(performance_report_params)
    @performance_report.user = current_user
    authorize @performance_report
    if @performance_report.save
      redirect_to(@performance_report, make_notice)
    else
      render :new
    end
  end

  def update
    if @performance_report.update(performance_report_params)
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
    authorize @performance_report
  end

  def performance_report_params
    params.require(:performance_report).permit(:period_start, :period_end, :users_id,
      :report_content)
  end
end
