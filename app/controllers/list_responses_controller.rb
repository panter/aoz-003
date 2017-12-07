class ListResponsesController < ApplicationController
  def feedbacks
    authorize :list_response
    @feedbacks = Feedback.created_asc.not_marked_done.paginate(page: params[:page])
  end

  def hours
    authorize :list_response
    @hours = Hour.created_asc.not_marked_done.paginate(page: params[:page])
  end

  def mark_feedback_done
    feedback = Feedback.find(params[:id])
    authorize :list_response
    feedback.update(marked_done_by: current_user)
    redirect_to list_responses_feedbacks_path, notice: 'Erfolgreich als erledigt markiert'
  end

  def mark_trial_feedback_done
    trial_feedback = TrialFeedback.find(params[:id])
    authorize :list_response
    trial_feedback.update(marked_done_by: current_user)
  end

  def mark_hour_done
    hour = Hour.find(params[:id])
    authorize :list_response
    hour.update(marked_done_by: current_user)
  end
end
