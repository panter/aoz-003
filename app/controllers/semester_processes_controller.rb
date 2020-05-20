class SemesterProcessesController < ApplicationController
  before_action :set_semester_process, only: [:edit, :update, :overdue]
  before_action :set_semester, only: [:new, :create]

  def new
    @semester_process = SemesterProcess.new(semester: @selected_semester, kind: :mail)
    new_or_edit
  end

  def edit
    @semester_process.kind = :mail
    new_or_edit
  end

  def create
    @semester_process = SemesterProcess.new(semester_process_params.slice(:kind, :semester))
    if update_or_create
      redirect_to semester_process_volunteers_path, notice: I18n.t('semester_processes.create.notice')
    else
      render :new
    end
  end

  def update
    @save = params[:save_records]
    if update_or_create
      redirect_to semester_process_volunteers_path, notice: I18n.t("semester_processes.update.notice.#{semester_process_params[:kind]}")
    else
      render :new
    end
  end

  def overdue
    @semester_process.kind = :reminder
    @volunteers = Volunteer.joins(:semester_process_volunteers)
      .merge(@semester_process.semester_process_volunteers.unsubmitted)
    @semester_process.build_semester_volunteers(@volunteers, preselect: true)

    @spvs_sorted = sort_volunteers

    params[:semester] = Semester.to_s(@semester_process.semester.begin)

    if EmailTemplate.half_year_process_overdue.active.any?
      template = EmailTemplate.half_year_process_overdue.active.first.slice(:subject, :body)
      @semester_process.assign_attributes(reminder_mail_body_template: template[:body], reminder_mail_subject_template: template[:subject])
    else
      redirect_to new_email_template_path, notice: I18n.t('semester_processes.update.notice.missing_template')
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
      redirect_to new_email_template_path, notice: I18n.t('semester_processes.update.notice.missing_template')
    end
  end

  def sort_volunteers
    @semester_process.new_semester_process_volunteers.sort do |spv1, spv2|
      spv1.volunteer.contact.full_name <=> spv2.volunteer.contact.full_name
    end
  end

  def update_or_create
    authorize @semester_process

    @semester_process.kind = semester_process_params[:kind]
    @semester_process.creator = current_user

    if @semester_process.kind == 'mail'
      @semester_process.assign_attributes(
        mail_body_template:    semester_process_params[:body],
        mail_subject_template: semester_process_params[:subject]
      )
      @volunteers = Volunteer.semester_process_eligible(@semester_process.semester)
      @semester_process.build_semester_volunteers(@volunteers, selected: selected_volunteers, save_records: true)
      @semester_process.build_volunteers_feedbacks_and_mails
    else
      @semester_process.assign_attributes(
        reminder_mail_body_template:    semester_process_params[:body],
        reminder_mail_subject_template: semester_process_params[:subject]
      )

      @volunteers = Volunteer.joins(:semester_process_volunteers)
        .merge(@semester_process.semester_process_volunteers.unsubmitted)
        .find(selected_volunteers)
      @semester_process.build_volunteers_feedbacks_and_mails(@volunteers.map(&:id))
    end

    @semester_process.save
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
