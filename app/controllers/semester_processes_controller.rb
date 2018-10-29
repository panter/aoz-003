class SemesterProcessesController < ApplicationController
  before_action :set_semester_process, only: [:show, :edit, :update]
  before_action :set_semester, only: [:new, :create]

  def index
    authorize SemesterProcess
    @semester_processes = SemesterProcess.all.paginate(page: params[:page])
  end

  def show; end

  def new
    @semester_process = SemesterProcess.new(semester: @selected_semester)
    @semester_process.build_semester_volunteers(@volunteers)
    authorize @semester_process
    @spvs_sorted = @semester_process.semester_process_volunteers.sort { |spv1, spv2| spv1.volunteer.contact.full_name <=> spv2.volunteer.contact.full_name}
    @seme
    if EmailTemplate.half_year_process_email.active.any?
      template = EmailTemplate.half_year_process_email.active.first.slice(:subject, :body)
      @semester_process.assign_attributes(mail_body_template: template[:body], mail_subject_template: template[:subject])
    else
      redirect_to new_email_template_path,
        notice: 'Sie müssen eine aktive E-Mailvorlage haben,
        bevor Sie eine Halbjahres Erinnerung erstellen können.'
    end
  end

  def edit; end

  def create
    @semester_process = SemesterProcess.new(semester_process_params.slice(:semester))
    @semester_process.creator = current_user
    authorize @semester_process

    @semester_process.assign_attributes(
      mail_body_template:    semester_process_params[:body],
      mail_subject_template: semester_process_params[:subject]
    )

    @semester_process.build_semester_volunteers(@volunteers, selected_volunteers: selected_volunteers)
    @semester_process.build_volunteers_hours_feedbacks_and_mails

    if @semester_process.save
      redirect_to semester_process_volunteers_path, notice: 'Semester process was successfully created.'
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

  private

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

    semester_form_param = Semester.parse(params[:semester_process]&.fetch(:semester))
    @volunteers = Volunteer.semester_process_eligible(semester_form_param || @selected_semester)
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
      :sort,
      semester_process_volunteers_attributes: [
        :volunteer_id, :selected
      ]
    )
  end
end
