class GroupAssignmentsController < ApplicationController
  before_action :set_group_assignment

  def update
    if @group_assignment.update(group_assignment_params)
      redirect_to last_submitted_hours_and_feedbacks_group_assignment_path,
        notice: 'Die Stunden und Feedbacks wurden erfolgreich bestätigt.'
    else
      redirect_to last_submitted_hours_and_feedbacks_group_assignment_path
    end
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

  def last_submitted_hours_and_feedbacks
    @last_submitted_hours = @group_assignment.hours_since_last_submitted
    @last_submitted_feedbacks = @group_assignment.feedbacks_since_last_submitted
  end

  private

  def set_group_assignment
    @group_assignment = GroupAssignment.find(params[:id])
    authorize @group_assignment
  end

  def group_assignment_params
    params.require(:group_assignment).permit(:submitted_at)
  end
end
