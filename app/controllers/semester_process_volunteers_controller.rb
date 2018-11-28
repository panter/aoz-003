class SemesterProcessVolunteersController < ApplicationController
  before_action :prepare_review, :initialize_nested_objects, only: [:review_semester, :submit_review]
  before_action :set_semester_process_volunteer, only: [:show, :edit, :update, :take_responsibility, :mark_as_done, :update_notes]
  before_action :set_semester, only: [:index]

  include SemesterProcessVolunteerHelper

  def review_semester; end

  def submit_review
    # you shall not pass
    return if @semester_process_volunteer.commited_at

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
    flash[:alert] = exception.message
    render :review_semester
  end

  def index
    authorize SemesterProcessVolunteer
    semester = Semester.parse(params[:semester])
    @semester_process = SemesterProcess.find_by_semester(semester).last
    @q = SemesterProcessVolunteer.index(@semester_process).ransack(params[:q])
    @q.sorts = ['volunteer_contact_last_name asc'] if @q.sorts.empty?
    @spvs = @q.result.paginate(page: params[:page])
    set_responsibles
    set_reviewers
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

  def take_responsibility
    respond_to do |format|
      if @spv.update(responsible: current_user)
        format.html { redirect_to semester_process_volunteers_path, notice: 'Semester Prozess übernommen.' }
        format.json do
          render json: { link: url_for(@spv.responsible), at: I18n.l(@spv.responsibility_taken_at.to_date),
                         email: @spv.responsible.email }, status: :ok
        end
      else
        format.html { redirect_to semester_process_volunteers_path, notice: 'Fehler: Übernehmen fehlgeschlagen.' }
          format.json { render json: { errors: @spv.errors.messages }, status: :unprocessable_entity }
      end
    end
  end

  def mark_as_done
    respond_to do |format|
      if @spv.update(reviewed_by: current_user, reviewed_at: Time.zone.now)
        format.html { redirect_to semester_process_volunteers_path, notice: 'Semester Prozess quittiert.' }
        format.json do
          render json: { link: url_for(@spv.reviewed_by), at: I18n.l(@spv.reviewed_at.to_date),
                         email: @spv.reviewed_by.email }, status: :ok
        end
      else
        format.html { redirect_to semester_process_volunteers_path, notice: 'Fehler: Quittieren fehlgeschlagen.' }
        format.json { render json: { errors: @spv.errors.messages }, status: :unprocessable_entity }
      end
    end
  end

  def update_notes
    updated_notes = semester_process_volunteer_params[:notes]
    @spv.update_attribute(:notes, updated_notes)
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
      volunteer_attributes: [:id, :waive, :iban, :bank],
      semester_feedbacks_attributes: [[semester_feedback: [:mission, :goals, :achievements, :future, :comments, :conversation, :spv_mission_id]],
                                     [hour: [:hours, :spv_mission_id, :activity]]]
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

  def set_responsibles
    @responsibles = SemesterProcessVolunteer.joins(responsible: [profile: [:contact]])
      .distinct
      .select('users.id, contacts.full_name')
      .map do |responsible|
        {
          q: :responsible_id_eq,
          text: "Übernommen von #{responsible.full_name}",
          value: responsible.id
        }
      end
  end

  def set_reviewers
    @reviewers = SemesterProcessVolunteer.joins(reviewed_by: [profile: [:contact]])
      .distinct
      .select('users.id, contacts.full_name')
      .map do |reviewed_by|
        {
          q: :reviewed_by_id_eq,
          text: "Quittiert von #{reviewed_by.full_name}",
          value: reviewed_by.id
        }
      end
  end

  def semester_process_volunteer_params
    params.require(:semester_process_volunteer).permit(:semester, :notes)
  end
end
