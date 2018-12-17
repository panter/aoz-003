class FeedbacksController < ApplicationController
  def index
    authorize Feedback
    @feedbacks = if params[:assignment_id]
                   SemesterFeedback.where(assignment_id: params[:assignment_id])
                 elsif params[:group_offer_id]
                   SemesterFeedback.where(group_assignment_id: GroupAssignment.where(group_offer_id: params[:group_offer_id]).ids)
                 else
                  []
                 end
  end
end
