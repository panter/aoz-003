class GroupAssignmentsController < ApplicationController
  def show
    @group_assignment = GroupAssignment.find(params[:id])
    authorize @group_assignment
    respond_to do |format|
      format.pdf do
        render pdf: "group_assignment_#{@group_assignment.id}",
          template: 'group_assignments/show.pdf.slim',
          layout: 'pdf.pdf', encoding: 'UTF-8'
      end
    end
  end
end
