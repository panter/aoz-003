class AssignmentsController < ApplicationController
  before_action :set_assignment,
    except: [:index, :terminated_index, :volunteer_search, :client_search, :new, :create, :find_client]

  def index
    authorize Assignment
    set_default_filter(active_or_not_yet_active: 'true')
    @q = policy_scope(Assignment).ransack(params[:q])
    @q.sorts = ['period_start desc'] if @q.sorts.empty?
    @assignments = @q.result
    respond_to do |format|
      format.xlsx
      format.html do
        @assignments = @assignments.paginate(page: params[:page],
          per_page: params[:print] && @assignments.size)
      end
    end
  end

  def terminated_index
    authorize Assignment
    set_default_filter(termination_verified_by_id_null: 'true')
    @q = policy_scope(Assignment).ended.ransack(params[:q])
    @assignments = @q.result.paginate(page: params[:page])
  end

  def volunteer_search
    authorize Assignment
    @q = policy_scope(Assignment).ransack volunteer_contact_full_name_cont: params[:term]
    @assignments = @q.result distinct: true
    respond_to do |format|
      format.json
    end
  end

  def client_search
    authorize Assignment
    @q = policy_scope(Assignment).ransack client_contact_full_name_cont: params[:term]
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
    @assignment.assign_attributes(assignment_params)
    @assignment.period_end_set_by = current_user if @assignment.will_save_change_to_period_end?
    if @assignment.save
      create_update_redirect
    else
      render :edit
    end
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
  end

  def update_submitted_at
    @assignment.update(submitted_at: Time.zone.now)
    redirect_to last_submitted_hours_and_feedbacks_assignment_path,
      notice: 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'
  end

  def terminate
    return if @assignment.period_end.present?
    redirect_back(fallback_location: @assignment.volunteer,
      notice: 'Für diesen Einsatz wurde noch keine Ende definiert.')
  end

  def update_terminated_at
    @assignment.volunteer.waive = waive_param_true?
    @assignment.assign_attributes(assignment_params.except(:volunteer_attributes)
      .merge(termination_submitted_at: Time.zone.now, termination_submitted_by: current_user))
    if @assignment.save && terminate_reminder_mailing
      NotificationMailer.termination_submitted(@assignment).deliver_now
      redirect_to @assignment.volunteer, notice: 'Der Einsatz ist hiermit abgeschlossen.'
    else
      redirect_back(fallback_location: terminate_assignment_path(@assignment))
    end
  end

  def verify_termination
    @assignment.verify_termination(current_user)
    redirect_back(fallback_location: terminated_index_assignments_path)
    flash[:notice] = 'Der Einsatz wurde erfolgreich quittiert.'
  end

  private

  def create_update_redirect
    if @assignment.saved_change_to_period_end?(from: nil)
      redirect_to terminated_index_assignments_path,
        notice: 'Die Einsatzbeendung wurde initiiert.'
    else
      redirect_to(volunteer? ? @assignment.volunteer : assignments_url, make_notice)
    end
  end

  def waive_param_true?
    assignment_params[:volunteer_attributes][:waive] == '1'
  end

  def terminate_reminder_mailing
    ReminderMailingVolunteer.termination_for(@assignment).map do |rmv|
      rmv.mark_process_submitted(current_user, terminate_parent_mailing: true)
    end
  end

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
      :client_id, :volunteer_id, :period_start, :period_end, :waive,
      :performance_appraisal_review, :probation_period, :home_visit,
      :first_instruction_lesson, :termination_submitted_at, :terminated_at,
      :term_feedback_activities, :term_feedback_problems, :term_feedback_success,
      :term_feedback_transfair, :comments, :additional_comments,
      volunteer_attributes: [:waive]
    )
  end
end
