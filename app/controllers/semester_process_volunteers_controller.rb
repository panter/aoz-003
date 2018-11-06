class SemesterProcessVolunteersController < ApplicationController
  before_action :prepare_review, only: [:review_semester, :submit_review]
  before_action :initialize_feedback, only: [:review_semester, :submit_review]
  before_action :set_semester_process_volunteer, only: [:show, :edit, :update]
  before_action :set_semester, only: [:index]

  include SemesterProcessVolunteerHelper

  def review_semester; end

  def submit_review
    set_reviewed
    assign_reviewed_attributes
    @semester_process_volunteer.volunteer.validate_waive_and_bank = true
    @semester_process_volunteer.missions.each { |m| m.semester_feedback.build }
    @semester_process_volunteer.missions.each { |m| m.hours.build }
    if @semester_process_volunteer.save && @volunteer.save
      redirect_to(
        review_semester_semester_process_volunteer_path(@semester_process_volunteer),
        notice: 'Successfully reviewed.'
      )
    else
      null_reviewed
      errors = @semester_process_volunteer.errors.full_messages + @volunteer.errors.full_messages
      render :review_semester, notice: errors
    end
  end

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

  def prepare_review
    # careful cuz mission id can be present in both missions
    @semester_process_volunteer = SemesterProcessVolunteer.find(params[:id])
    #@hours = @semester_process_volunteer.hours
    @volunteer = @semester_process_volunteer.volunteer
    @missions = @semester_process_volunteer.missions
    authorize @semester_process_volunteer
  end

  def review_params
    params.require(:semester_process_volunteer).permit(
      volunteer_attributes: [:waive, :iban, :bank],
      semester_feedback: [:mission, :goals, :achievements, :future, :comments, :conversation],
      hour_attributes: [:hours])
  end

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
