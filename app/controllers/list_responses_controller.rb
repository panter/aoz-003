class ListResponsesController < ApplicationController
  def feedbacks
    authorize :list_response, :feedbacks?
    @feedbacks = Feedback.order(created_at: :asc).where(marked_done_by_id: nil).paginate(page: params[:page])
  end

  def hours
    authorize :list_response, :hours?
    @hours = Hour.all
  end

  def mark_feedback_done
    feedback = Feedback.find(params[:id])
    authorize :list_response, :mark_feedback_done?
    feedback.update(marked_done_by: current_user)
    redirect_to list_responses_feedbacks_path, notice: 'Erfolgreich erledigt markiert'
  end

  def mark_trial_feedback_done
    trial_feedback = TrialFeedback.find(params[:id])
    authorize :list_response, :mark_trial_feedback_done?
    trial_feedback.update(marked_done_by: current_user)
  end

  def mark_hour_done
    hour = Hour.find(params[:id])
    authorize :list_response, :mark_hour_done?
    hour.update(marked_done_by: current_user)
  end
end
