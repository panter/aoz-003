class SemesterProcessesController < ApplicationController
  before_action :set_semester_process, only: [:show, :edit, :update, :destroy]

  def index
    authorize SemesterProcess
    @semester_processes = SemesterProcess.all.paginate(page: params[:page])
  end

  def show; end

  def new
    @semester_process = SemesterProcess.new
    authorize @semester_process
  end

  def edit; end

  def create
    @semester_process = SemesterProcess.new(semester_process_params)
    @semester_process.creator = current_user
    authorize @semester_process
    if @semester_process.save
      redirect_to @semester_process, notice: 'Semester process was successfully created.'
    else
      render :new
    end
  end

  def update
    if @semester_process.update(semester_process_params)
      redirect_to @semester_process, notice: 'Semester process was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @semester_process.destroy
      redirect_to semester_processes_url, notice: 'Semester process was successfully destroyed.'
    else
      redirect_to semester_processes_url, notice: 'Failure notice'
    end
  end

  private

  def set_semester_process
    @semester_process = SemesterProcess.find(params[:id])
    authorize @semester_process
  end

  def semester_process_params
    params.require(:semester_process).permit(:period_start, :period_end)
  end
end
