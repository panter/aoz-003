# this is obsolete, only used for the index action. we should move the action and the view to semester_feedbacks
class FeedbacksController < ApplicationController
  def index
    semester_feedback = SemesterFeedback.joins(:volunteer).where(:volunteers => { id: params[:volunteer_id] })
    @feedbacks = if params[:assignment_id]
                  semester_feedback.where(assignment_id: params[:assignment_id])
                 elsif params[:group_offer_id]
                  semester_feedback.where(group_assignment_id: GroupAssignment.where(group_offer_id: params[:group_offer_id]).ids)
                 else
                  []
                 end
    authorize @feedbacks
    @feedbacks = policy_scope(@feedbacks)
  end
end
