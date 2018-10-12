class SemesterProcessesController < ApplicationController
  before_action :set_semester_process, only: [:show, :edit, :update, :destroy]
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
  end

  def edit; end

  def create
    @semester_process = SemesterProcess.new(semester_process_params.slice(:semester))
    @semester_process.creator = current_user
    @semester_process.build_semester_volunteers(@volunteers, selected_volunteers)
    @semester_process.build_volunteers_hours_feedbacks_and_mails
    authorize @semester_process
    if @semester_process.save
      redirect_to @semester_process, notice: 'Semester process was successfully created.'
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

  def destroy
    if @semester_process.destroy
      redirect_to semester_processes_url, notice: 'Semester process was successfully destroyed.'
    else
      redirect_to semester_processes_url, notice: 'Failure notice'
    end
  end

  private

  def set_semester_process
    @semester_process = SemesterProcess.find(params[:id])
    authorize @semester_process
  end

  def set_semester
    @semester = Semester.new
    params[:semester] = @semester.year_number unless params[:semester]
    @selected_semester = Semester.new(*params[:semester].split(',').map(&:to_i)).current
    @volunteers = Volunteer.semester_process_eligible(@selected_semester)
  end

  def selected_volunteers
    semester_process_params[:semester_process_volunteers_attributes]
      .select { |_key, value| value['selected'] == '1' }
      .to_h.map { |_key, value| value[:volunteer_id].to_i }
  end

  def semester_process_params
    params.require(:semester_process).permit(
      :semester,
      semester_process_volunteers_attributes: [
        :volunteer_id, :selected
      ]
    )
  end
end
