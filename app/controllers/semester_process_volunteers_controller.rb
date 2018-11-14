class SemesterProcessVolunteersController < ApplicationController
  before_action :prepare_review, only: [:review_semester, :submit_review]
  before_action :set_semester_process_volunteer, only: [:show, :edit, :update]
  before_action :set_semester, only: [:index]

  include SemesterProcessVolunteerHelper

  def review_semester
    initialize_nested_objects
  end

  def submit_review
    # you shall not pass
    return if @semester_process_volunteer.commited_at

    initialize_nested_objects
    set_reviewed
    assign_volunteer_attributes
    build_nested_objects

    @semester_process_volunteer.volunteer.validate_waive_and_bank = true


    ActiveRecord::Base.transaction do
      @semester_process_volunteer.save!
      @volunteer.save!

      @nested_objects.each do |_key, hash|
        hash.each { |_id, obj| obj.save! }
      end
    end

    redirect_to review_semester_semester_process_volunteer_path(@semester_process_volunteer), notice: t('.success')

  rescue ActiveRecord::RecordInvalid => exception
    logger.error exception.message
    null_reviewed
    render :review_semester
  end

  def index
    authorize SemesterProcessVolunteer

    @spvs = SemesterProcessVolunteer.index(Semester.parse(params[:semester])).page(params[:page])
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
    @semester_process_volunteer = SemesterProcessVolunteer.find(params[:id])
    authorize @semester_process_volunteer
    @volunteer = @semester_process_volunteer.volunteer
    @missions = @semester_process_volunteer.missions
  end

  def review_params
    params.require(:semester_process_volunteer).permit(
      volunteer_attributes: [:id ,:waive, :iban, :bank],
      semester_feedbacks_attributes: [[semester_feedback: [:mission, :goals, :achievements, :future, :comments, :conversation, :spv_mission_id]],
                                     [hour: [:hours, :spv_mission_id ]]])

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
