class SemesterProcessVolunteersController < ApplicationController
  before_action :set_semester_process_volunteer, only: [:show, :edit, :update]
  before_action :set_semester, only: [:index]

  def index
    authorize SemesterProcessVolunteer

    @spvs = SemesterProcessVolunteer.index(Semester.parse(params[:semester])).page(params[:page])
  end

  def show; end

  def edit; end

  def update
    if @spv.update(semester_process_params)
      redirect_to @spv, notice: 'Semester process was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_semester_process_volunteer
    @spv = SemesterProcessVolunteer.find(params[:id])
    authorize @spv
    @semester_process = @spv.semester_process
    @volunteer = @spv.volunteer
  end

  def set_semester
    @semester = Semester.new
    if params[:semester]
      @selected_semester = Semester.parse(params[:semester])
    else
      @selected_semester = @semester.previous
      params[:semester] = Semester.to_s(@selected_semester)
    end
  end

  def semester_process_volunteer_params
    params.require(:semester_process_volunteer).permit(:semester)
  end
end
