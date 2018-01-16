class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [
    :show, :edit, :update, :destroy, :finish, :update_termination_submitted_at,
    :last_submitted_hours_and_feedbacks, :update_submitted_at
  ]

  def index
    authorize Assignment
    @q = policy_scope(Assignment).ransack(params[:q])
    @q.sorts = ['period_start desc'] if @q.sorts.empty?
    @assignments = @q.result
    activity_filter
    respond_to do |format|
      format.xlsx
      format.html do
        @assignments = @assignments.paginate(page: params[:page],
          per_page: params[:print] && @assignments.size)
      end
    end
  end

  def search
    authorize Assignment
    @q = policy_scope(Assignment).ransack volunteer_contact_full_name_cont: params[:term]
    @assignments = @q.result distinct: true
    respond_to do |format|
      format.json
    end
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "assignment_#{@assignment.id}", template: 'assignments/show.html.slim',
          layout: 'pdf.pdf', encoding: 'UTF-8'
      end
    end
  end

  def new
    @assignment = Assignment.new
    authorize @assignment
  end

  def edit; end

  def create
    @assignment = Assignment.new(assignment_params.merge(creator_id: current_user.id))
    authorize @assignment
    if @assignment.save
      redirect_to assignments_url, make_notice
    else
      render :new
    end
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to(volunteer? ? @assignment.volunteer : assignments_url, make_notice)
    else
      render :edit
    end
  end

  def destroy
    redirect_to assignments_url, make_notice
  end

  def find_client
    set_volunteer
    @q = policy_scope(Client).need_accompanying.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @need_accompanying = @q.result.paginate(page: params[:page])
  end

  def last_submitted_hours_and_feedbacks
    @last_submitted_hours = @assignment.hours_since_last_submitted
    @last_submitted_feedbacks = @assignment.feedbacks_since_last_submitted
    return if params[:rmv_id].blank?
    rmv = ReminderMailingVolunteer.find(params[:rmv_id].to_i)
    return if rmv.reminder_mailable != @assignment || rmv.volunteer.user != current_user
    rmv.update(link_visits: rmv.link_visits + 1)
  end

  def update_submitted_at
    @assignment.update(submitted_at: Time.zone.now)
    redirect_to last_submitted_hours_and_feedbacks_assignment_path,
      notice: 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'
  end

  def finish; end

  def update_termination_submitted_at
    @assignment.update(termination_submitted_at: Time.zone.now)
    redirect_to @assignment.volunteer, notice: 'Der Einsatz ist hiermit abgeschlossen.'
  end

  private

  def activity_filter
    return unless params[:q] && params[:q][:active_eq]
    @assignments = params[:q][:active_eq] == 'true' ? @assignments.active : @assignments.inactive
  end

  def set_client
    @client = Client.find(params[:id])
    authorize Assignment
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
    authorize Assignment
  end

  def set_assignment
    @assignment = Assignment.find(params[:id])
    authorize @assignment
  end

  def assignment_params
    params.require(:assignment).permit(
      :client_id, :volunteer_id, :period_start, :period_end,
      :performance_appraisal_review, :probation_period, :home_visit,
      :first_instruction_lesson, :termination_submitted_at
    )
  end
end
