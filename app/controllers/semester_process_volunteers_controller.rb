class SemesterProcessVolunteersController < ApplicationController
  before_action :prepare_review, only: [:review_semester, :submit_review]
  before_action :initialize_feedback, only: [:review_semester, :submit_review]
  before_action :set_semester_process_volunteer, only: [:show, :edit, :update]
  before_action :set_semester, only: [:index]

  include SemesterProcessVolunteerHelper

  def review_semester
    @hour = Hour.new
  end

  def submit_review
    assign_reviewed_attributes
    set_reviewed
    @semester_process_volunteer.volunteer.validate_waive_and_bank = true
    begin
      ActiveRecord::Base.transaction do
        @semester_process_volunteer.semester_feedbacks << @feedback
        @hour.save! unless @hour.hours == 0 || @hour.hours.blank?
        @semester_process_volunteer.save!
        @volunteer.save!
      end

      redirect_to(
        review_semester_semester_process_volunteer_path(@semester_process_volunteer),
        notice: 'Successfully reviewed.'
      )
    rescue ActiveRecord::RecordInvalid => exception
      null_reviewed
      @hours.reload
      render :review_semester, notice: exception
    end
  end

  def index
    authorize SemesterProcessVolunteer
    semester = Semester.parse(params[:semester])
    @spvs = SemesterProcessVolunteer.index(semester).page(params[:page])
    @semester_process = SemesterProcess.find_by_semester(semester)
    @spvs_sorted = @spvs.sort { |spv1, spv2| spv1.volunteer.contact.full_name <=> spv2.volunteer.contact.full_name}
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
    @hours = @semester_process_volunteer.hours
    @volunteer = @semester_process_volunteer.volunteer
    @mission = @semester_process_volunteer.missions.first
    authorize @semester_process_volunteer
  end

  def review_params
    params.require(:semester_process_volunteer).permit(
      volunteer_attributes: [:waive, :iban, :bank],
      semester_feedback: [:goals, :achievements, :future, :comments, :conversation],
      hour: [:hours]
    )
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
