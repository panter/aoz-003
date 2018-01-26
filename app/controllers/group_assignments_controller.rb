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
    if @group_assignment.update(group_assignment_params)
      if @group_assignment.saved_change_to_period_end? && @group_assignment.ended?
        redirect_to terminated_index_group_assignments_path,
          notice: 'Einsatzende wurde erfolgreich gesetzt.'
      else
        redirect_to @group_assignment.group_offer, make_notice
      end
    else
      render :edit
    end
  end

  def set_end_today
    if @group_assignment.update(period_end: Time.zone.today)
      redirect_to terminated_index_group_assignments_path,
        notice: 'Einsatzende wurde erfolgreich gesetzt.'
    else
      redirect_to @group_assignment.group_offer, notice: 'Einsatzende konnte nicht gesetzt werden.'
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

  def verify_termination; end

  private

  def set_group_assignment
    @group_assignment = GroupAssignment.find(params[:id])
    authorize @group_assignment
  end

  def group_assignment_params
    params.require(:group_assignment).permit(:period_start, :period_end, :responsible)
  end
end
