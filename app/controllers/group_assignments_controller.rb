class GroupAssignmentsController < ApplicationController
  before_action :set_group_assignment

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
  end

  private

  def set_group_assignment
    @group_assignment = GroupAssignment.find(params[:id])
    authorize @group_assignment
  end
end
