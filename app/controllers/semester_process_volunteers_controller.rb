class SemesterProcessVolunteersController < ApplicationController
  before_action :set_semester_process_volunteer, only: [:show, :edit, :update]

  def index
    authorize SemesterProcessVolunteer
    @semester_process = SemesterProcess.find(params[:semester_process_id])
    @semester_process_volunteers = @semester_process.semester_process_volunteers
  end

  def show; end

  def edit; end

  def update
    if @semester_process_volunteer.update(semester_process_params)
      redirect_to @semester_process_volunteer, notice: 'Semester process was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_semester_process_volunteer
    @semester_process_volunteer = SemesterProcess.find(params[:id])
    authorize @semester_process_volunteer
    @semester_process = @semester_process_volunteer.semester_process
    @volunteer = @semester_process_volunteer.volunteer
  end

  def semester_process_volunteer_params
    params.require(:semester_process_volunteer).permit(:semester)
  end
end
