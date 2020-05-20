class GroupAssignmentsController < ApplicationController
  before_action :set_group_assignment, except:
    [:create, :terminated_index, :hours_and_feedbacks_submitted]

  def terminated_index
    authorize GroupAssignment
    set_default_filter(termination_verified_by_id_null: 'true')
    @q = policy_scope(GroupAssignment).ended.ransack(params[:q])
    @q.sorts = ['updated_at desc'] if @q.sorts.empty?
    @group_assignments = @q.result
  end

  def show
    respond_to do |format|
      format.pdf do
        render_pdf_attachment @group_assignment
      end
    end
  end

  def create
    @group_assignment = GroupAssignment.new(group_assignment_params)
    @group_assignment.created_by = current_user
    @group_assignment.default_values
    authorize @group_assignment
    if save_with_pdf @group_assignment, 'show.pdf'
      redirect_to request.referer || @group_assignment.group_offer,
                  notice: 'Freiwillige/r erfolgreich hinzugefügt.'
    else
      redirect_to request.referer || @group_assignment.group_offer,
                  notice: @group_assignment.errors.full_messages.first
    end
  end

  def edit; end

  def update
    @group_assignment.assign_attributes(group_assignment_params)
    @group_assignment.created_by = current_user
    period_end_set_notice, redirect_path = handle_period_end
    if save_with_pdf @group_assignment, 'show.pdf'
      create_redirect period_end_set_notice, redirect_path
    else
      render :edit
    end
  end

  def set_end_today
    if @group_assignment.update(period_end: Time.zone.today, period_end_set_by: current_user)
      create_redirect 'Einsatzende wurde erfolgreich gesetzt.'
    else
      create_redirect 'Einsatzende konnte nicht gesetzt werden.'
    end
  end

  def last_submitted_hours_and_feedbacks
    @last_submitted_hours = @group_assignment.hours_since_last_submitted
    @last_submitted_feedbacks = @group_assignment.feedbacks_since_last_submitted
    @volunteer = @group_assignment.volunteer
    return if params[:rmv_id].blank?

    rmv = ReminderMailingVolunteer.find(params[:rmv_id].to_i)
    return if rmv.reminder_mailable != @group_assignment || rmv.volunteer.user != current_user

    rmv.update(link_visits: rmv.link_visits + 1)
  end

  def submit_feedback
    @group_assignment.volunteer.assign_attributes(group_assignment_params[:volunteer_attributes]
      .slice(:waive, :bank, :iban))
    @group_assignment.submit_feedback = current_user
    if @group_assignment.save
      redirect_to default_redirect || hours_and_feedbacks_submitted_assignments_path
    else
      redirect_to(
        last_submitted_hours_and_feedbacks_group_assignment_path(@assignment),
        notice: 'Das bestätigen des Feedbacks ist fehlgeschlagen.'
      )
    end
  end

  def terminate; end

  def update_terminated_at
    @group_assignment.assign_attributes(group_assignment_params.merge(
                                          termination_submitted_at: Time.zone.now,
                                          termination_submitted_by: current_user
                                        ))

    if @group_assignment.save && terminate_reminder_mailing
      NotificationMailer.termination_submitted(@group_assignment).deliver_now
      redirect_to @group_assignment.volunteer,
                  notice: 'Der Gruppeneinsatz ist hiermit abgeschlossen.'
    else
      redirect_back(fallback_location: terminate_group_assignment_path(@group_assignment))
    end
  end

  def verify_termination
    @group_assignment.verify_termination(current_user)
    redirect_back(fallback_location: terminated_index_group_assignments_path)
    flash[:notice] = 'Der Gruppeneinsatz wurde erfolgreich quittiert.'
  end

  def hours_and_feedbacks_submitted
    authorize :group_assignment, :hours_and_feedbacks_submitted?
  end

  def reactivate
    state = @group_assignment.reactivate!(current_user) ? 'success' : 'failure'
    redirect_back fallback_location: edit_group_assignment_path(@group_assignment),
      notice: t("group_assignments.notices.reactivation.#{state}")
  end

  private

  def handle_period_end
    return unless @group_assignment.will_save_change_to_period_end?(from: nil)

    @group_assignment.period_end_set_by = current_user
    [
      'Einsatzende wurde erfolgreich gesetzt.',
      terminated_index_group_assignments_path
    ]
  end

  def create_redirect(notice_text = nil, default_path = nil)
    redirect_to default_redirect || default_path || polymorphic_path(@group_assignment.group_offer),
                notice: notice_text || make_notice[:notice]
  end

  def terminate_reminder_mailing
    ReminderMailingVolunteer.termination_for(@group_assignment).map do |rmv|
      rmv.mark_process_submitted(current_user, terminate_parent_mailing: true)
    end
  end

  def set_group_assignment
    @group_assignment = GroupAssignment.find(params[:id])
    authorize @group_assignment
  end

  def create_update_redirect
    if @group_assignment.saved_change_to_period_end?(from: nil)
      redirect_to terminated_index_group_assignments_path,
                  notice: 'Die Einsatzbeendung wurde initiiert.'
    else
      redirect_to @group_assignment.group_offer, make_notice
    end
  end

  def group_assignment_params
    params.require(:group_assignment).permit(
      :period_start, :period_end, :termination_submitted_at, :terminated_at, :responsible,
      :term_feedback_activities, :term_feedback_problems, :term_feedback_success,
      :redirect_to, :term_feedback_aoz, :comments, :additional_comments, :frequency,
      :description, :place, :happens_at, :agreement_text,
      :group_offer_id, :volunteer_id, :remaining_hours, :generate_pdf,
      volunteer_attributes: [:waive, :iban, :bank],
      trial_period_attributes: [:id, :end_date]
    )
  end
end
