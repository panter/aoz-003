class SemesterProcessesController < ApplicationController
  before_action :set_semester_process, only: [:show, :edit, :update, :overdue]
  before_action :set_semester, only: [:new, :create]

  include SemesterProcessHelper

  def index
    authorize SemesterProcess
    @semester_processes = SemesterProcess.all.paginate(page: params[:page])
  end

  def show; end

  def new
    @semester_process = SemesterProcess.new(semester: @selected_semester, kind: :mail )
    new_or_edit
  end

  def edit
    @semester_process.kind = :mail
    new_or_edit
  end

  def create
    @semester_process = SemesterProcess.new(semester_process_params.slice(:kind, :semester))
    update_or_create
  end

  def update
    @save = params[:save_records]
    update_or_create
  end

  def overdue
    @semester_process.kind = :reminder
    @volunteers = Volunteer.feedback_overdue(@semester_process.semester)
    @semester_process.build_semester_volunteers(@volunteers, preselect: true)

    @spvs_sorted = sort_volunteers

    params[:semester] = Semester.to_s(@semester_process.semester.begin)

    if EmailTemplate.half_year_process_overdue.active.any?
      template = EmailTemplate.half_year_process_overdue.active.first.slice(:subject, :body)
      @semester_process.assign_attributes(reminder_mail_body_template: template[:body], reminder_mail_subject_template: template[:subject])
    else
      redirect_to new_email_template_path,
        notice: 'Sie müssen eine aktive E-Mailvorlage haben,
        bevor Sie eine Halbjahres Erinnerung erstellen können.'
    end
  end

  private

  def new_or_edit
    authorize @semester_process

    @volunteers = Volunteer.semester_process_eligible(@semester_process.semester)
    @semester_process.build_semester_volunteers(@volunteers)

    @spvs_sorted = sort_volunteers

    if EmailTemplate.half_year_process_email.active.any?
      template = EmailTemplate.half_year_process_email.active.first.slice(:subject, :body)
      @semester_process.assign_attributes(mail_body_template: template[:body], mail_subject_template: template[:subject])
    else
      redirect_to new_email_template_path,
        notice: 'Sie müssen eine aktive E-Mailvorlage haben,
        bevor Sie eine Halbjahres Erinnerung erstellen können.'
    end
  end

  def update_or_create
    authorize @semester_process

    @semester_process.kind = semester_process_params[:kind]
    @semester_process.creator = current_user

    if @semester_process.kind == "mail"
      @semester_process.assign_attributes(
        mail_body_template:    semester_process_params[:body],
        mail_subject_template: semester_process_params[:subject]
      )
      @volunteers = Volunteer.semester_process_eligible(@semester_process.semester)
      @semester_process.build_semester_volunteers(@volunteers, selected: selected_volunteers, save_records: true)
      else
      @semester_process.assign_attributes(
        reminder_mail_body_template:    semester_process_params[:body],
        reminder_mail_subject_template: semester_process_params[:subject]
      )
      @volunteers = Volunteer.feedback_overdue(@semester_process.semester)
      
    end
    @semester_process.build_volunteers_hours_feedbacks_and_mails

    if @semester_process.save
      redirect_to semester_process_volunteers_path, notice: 'Semester process was successfully created and emails delivered.'
    else
      render :new
    end
  end

  def set_semester_process
    @semester_process = SemesterProcess.find(params[:id])
    authorize @semester_process
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

  def selected_volunteers
    semester_process_params[:semester_process_volunteers_attributes]
      .select { |_key, value| value['selected'] == '1' }
      .to_h.map { |_key, value| value[:volunteer_id].to_i }
  end

  def semester_process_params
    params.require(:semester_process).permit(
      :semester,
      :kind,
      :subject,
      :body,
      semester_process_volunteers_attributes: [
        :volunteer_id, :selected
      ]
    )
  end
end
