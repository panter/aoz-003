class AssignmentsController < ApplicationController
  before_action :set_assignment, except:
    [:index, :terminated_index, :volunteer_search, :client_search, :new, :create, :find_client,
     :hours_and_feedbacks_submitted]

  def index
    authorize Assignment
    set_default_filter(active_or_not_yet_active: 'true')
    @q = policy_scope(Assignment).ransack(params[:q])
    @q.sorts = ['period_start desc'] if @q.sorts.empty?
    @assignments = @q.result
    respond_to do |format|
      format.xlsx do
        render xlsx: 'index', filename: 'Begleitungen'
      end
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
      format.html do
        @pdf_created_at = @assignment.pdf_updated_at || Time.zone.now
      end

      format.pdf do
        render_pdf_attachment @assignment
      end
    end
  end

  def new
    @assignment = Assignment.new(client_id: params[:client_id], volunteer_id: params[:volunteer_id])
    @assignment.default_values
    authorize @assignment
  end

  def edit; end

  def create
    @assignment = Assignment.new(assignment_params.merge(creator_id: current_user.id))
    authorize @assignment
    if save_with_pdf @assignment
      redirect_to edit_assignment_path(@assignment), make_notice
    else
      render :new
    end
  end

  def update
    @assignment.assign_attributes(assignment_params)
    @assignment.period_end_set_by = current_user if @assignment.will_save_change_to_period_end?
    if save_with_pdf @assignment
      create_update_redirect
    else
      render :edit
    end
  end

  def find_client
    set_volunteer
    @q = policy_scope(Client).inactive.ransack(include_egal(params[:q]))
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @need_accompanying = @q.result.paginate(page: params[:page])
  end

  #special method for the Egal use case. Egal should be included and this is a hacking on the ransack search matchers to transform cont and eq to _in that permits the use of OR in the sql statement
  def include_egal(params)
    parameters = params.deep_dup
      if parameters.present? && parameters.key?("age_request_cont") && parameters["age_request_cont"]&.present?
        parameters["age_request_in"] = [parameters["age_request_cont"], "age_no_matter"]
        parameters.delete("age_request_cont")
      end
      if parameters.present? && parameters.key?("gender_request_eq")&& parameters["gender_request_eq"]&.present?
        parameters["gender_request_in"] = [parameters["gender_request_eq"], "no_matter"]
        parameters.delete("gender_request_eq")
      end
      return parameters
  end

  def last_submitted_hours_and_feedbacks
    @last_submitted_hours = @assignment.hours_since_last_submitted
    @last_submitted_feedbacks = @assignment.feedbacks_since_last_submitted
    @volunteer = @assignment.volunteer
  end

  def submit_feedback
    @assignment.volunteer.assign_attributes(assignment_feedback_params[:volunteer_attributes]
      .slice(:waive, :bank, :iban))
    @assignment.submit_feedback = current_user
    if @assignment.save
      redirect_to default_redirect || hours_and_feedbacks_submitted_assignments_path
    else
      redirect_to(
        last_submitted_hours_and_feedbacks_assignment_path(@assignment),
        notice: 'Das bestätigen des Feedbacks ist fehlgeschlagen.'
      )
    end
  end

  def terminate
    return if @assignment.period_end.present?
    redirect_back(fallback_location: @assignment.volunteer,
      notice: 'Für diesen Einsatz wurde noch keine Ende definiert.')
  end

  def update_terminated_at
    @assignment.assign_attributes(assignment_params.merge(
      termination_submitted_at: Time.zone.now,
      termination_submitted_by: current_user
    ))

    if @assignment.save && terminate_reminder_mailing
      NotificationMailer.termination_submitted(@assignment).deliver_now
      redirect_back fallback_location: terminate_assignment_path(@assignment),
        notice: 'Der Einsatz ist hiermit abgeschlossen.'
    else
      redirect_back fallback_location: terminate_assignment_path(@assignment)
    end
  end

  def verify_termination
    @assignment.verify_termination(current_user)
    redirect_to terminated_index_assignments_path(q: { termination_verified_by_id_not_null: true })
    flash[:notice] = 'Der Einsatz wurde erfolgreich quittiert.'
  end

  def hours_and_feedbacks_submitted
    authorize :assignment, :hours_and_feedbacks_submitted?
  end

  def reactivate
    state = @assignment.reactivate!(current_user) ? 'success' : 'failure'
    redirect_back fallback_location: edit_assignment_path(@assignment),
      notice: t("assignments.notices.reactivation.#{state}")
  end

  private

  def create_update_redirect
    if @assignment.saved_change_to_period_end?(from: nil) && (@assignment.ended? || @assignment.will_end_today?)
      redirect_to terminated_index_assignments_path,
        notice: 'Die Einsatzbeendung wurde initiiert.'
    else
      redirect_to edit_assignment_path(@assignment), make_notice
    end
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

  def assignment_feedback_params
    params.require(:assignment).permit(volunteer_attributes: [:waive, :iban, :bank])
  end

  def assignment_params
    params.require(:assignment).permit(
      :client_id, :volunteer_id, :period_start, :period_end,
      :performance_appraisal_review, :probation_period, :home_visit,
      :first_instruction_lesson, :termination_submitted_at, :terminated_at,
      :term_feedback_activities, :term_feedback_problems, :term_feedback_success,
      :term_feedback_transfair, :comments, :additional_comments,
      :agreement_text, :assignment_description, :frequency, :trial_period_end, :duration,
      :special_agreement, :first_meeting, :remaining_hours, :generate_pdf,
      volunteer_attributes: [:waive, :iban, :bank],
      trial_period_attributes: [:id, :end_date]
    )
  end
end
