class GroupAssignmentsController < ApplicationController
  before_action :set_group_assignment, except: [:terminated_index]

  def terminated_index
    authorize GroupAssignment
    @q = policy_scope(GroupAssignment).ended.ransack(params[:q])
    @q.sorts = ['updated_at desc'] if @q.sorts.empty?
    @group_assignments = @q.result
  end

  def show
    respond_to do |format|
      format.pdf do
        render pdf: "group_assignment_#{@group_assignment.id}",
          template: 'group_assignments/show.pdf.slim',
          layout: 'pdf.pdf', encoding: 'UTF-8'
      end
    end
  end

  def edit; end

  def update
    @group_assignment.assign_attributes(group_assignment_params)
    period_end_set_notice, redirect_action = handle_period_end
    if @group_assignment.save
      create_redirect_to(period_end_set_notice, action: redirect_action)
    else
      render :edit
    end
  end

  def set_end_today
    if @group_assignment.update(period_end: Time.zone.today, period_end_set_by: current_user)
      create_redirect_to('Einsatzende wurde erfolgreich gesetzt.')
    else
      create_redirect_to('Einsatzende konnte nicht gesetzt werden.')
    end
  end

  def last_submitted_hours_and_feedbacks
    @last_submitted_hours = @group_assignment.hours_since_last_submitted
    @last_submitted_feedbacks = @group_assignment.feedbacks_since_last_submitted
    return if params[:rmv_id].blank?
    rmv = ReminderMailingVolunteer.find(params[:rmv_id].to_i)
    return if rmv.reminder_mailable != @group_assignment || rmv.volunteer.user != current_user
    rmv.update(link_visits: rmv.link_visits + 1)
  end

  def update_submitted_at
    @group_assignment.update(submitted_at: Time.zone.now)
    redirect_to last_submitted_hours_and_feedbacks_group_assignment_path,
      notice: 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'
  end

  def terminate; end

  def update_terminated_at
    @group_assignment.volunteer.waive = waive_param_true?
    @group_assignment.assign_attributes(group_assignment_params.except(:volunteer_attributes)
      .merge(termination_submitted_at: Time.zone.now, termination_submitted_by: current_user))
    if @group_assignment.save && terminate_reminder_mailing
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

  private

  def handle_period_end
    if @group_assignment.will_save_change_to_period_end?(from: nil) && @group_assignment.ending?
      @group_assignment.period_end_set_by = current_user
      [
        'Einsatzende wurde erfolgreich gesetzt.',
        params[:redirect_to] || :terminated_group_assignments_index
      ]
    end
  end

  def create_redirect_to(notice_text = nil, action: nil)
    action ||= params[:redirect_to] unless params[:redirect_to] == 'show'
    redirect_to(
      polymorphic_path(@group_assignment.group_offer, action: action),
      notice: notice_text || make_notice[:notice]
    )
  end

  def waive_param_true?
    group_assignment_params[:volunteer_attributes][:waive] == '1'
  end

  def terminate_reminder_mailing
    ReminderMailingVolunteer.termination_for(@group_assignment).map do |rmv|
      rmv.mark_process_submitted(current_user, terminate_parent_mailing: true)
    end
    NotificationMailer.termination_submitted(@group_assignment).deliver_now
  end

  def set_group_assignment
    @group_assignment = GroupAssignment.find(params[:id])
    authorize @group_assignment
  end

  def group_assignment_params
    params.require(:group_assignment).permit(
      :period_start, :period_end, :termination_submitted_at, :terminated_at, :responsible,
      :term_feedback_activities, :term_feedback_problems, :term_feedback_success, :redirect_to,
      :term_feedback_transfair, volunteer_attributes: [:waive]
    )
  end
end
