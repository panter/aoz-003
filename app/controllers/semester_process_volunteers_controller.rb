class SemesterProcessVolunteersController < ApplicationController
  before_action :set_semester_process_volunteer, only: [:show, :edit, :update, :take_responsibility, :mark_as_done, :update_notes]
  before_action :set_semester, only: [:index]

  include SemesterProcessVolunteerHelper

  def review_semester
    authorize SemesterProcessVolunteer.find(params[:id])
    redirect_to review_semester_review_semester_url params[:id]
  end

  def index
    authorize SemesterProcessVolunteer
    semester = Semester.parse(params[:semester])
    @global_filters = {semester: params[:semester]}
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

  def set_semester
    @semester = Semester.new
    if params[:semester]
      @selected_semester = Semester.parse(params[:semester])
    else
      @selected_semester = @semester.current
      params[:semester] = Semester.to_s(@selected_semester)
    end
  end

  def semester_process_volunteer_params
    params.require(:semester_process_volunteer).permit(:semester, :notes)
  end
end
