# this is obsolete, only used for the index action. we should move the action and the view to semester_feedbacks
class FeedbacksController < ApplicationController
  def index
    @feedbacks = if params[:assignment_id]
                   SemesterFeedback.where(assignment_id: params[:assignment_id])
                 elsif params[:group_offer_id]
                   SemesterFeedback.where(group_assignment_id: GroupAssignment.where(group_offer_id: params[:group_offer_id]).ids)
                 else
                  []
                 end
    authorize @feedbacks
    @feedbacks = policy_scope(@feedbacks)
  end
end
