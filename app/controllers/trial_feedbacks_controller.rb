class TrialFeedbacksController < ApplicationController
  before_action :set_trial_feedback, only: [:show, :edit, :update, :destroy, :mark_as_done]
  before_action :set_trial_feedbackable
  before_action :set_volunteer, except: [:need_review]

  def index
    authorize TrialFeedback
    @trial_feedbacks = policy_scope(TrialFeedback).where(trial_feedbackable: @trial_feedbackable)
  end

  def show; end

  def new
    @trial_feedback = TrialFeedback.new(trial_feedbackable: @trial_feedbackable,
      volunteer: @volunteer, author: current_user)
    authorize @trial_feedback
    if params[:rmv_id].present?
      rmv = ReminderMailingVolunteer.find(params[:rmv_id].to_i)
      rmv.update(link_visits: rmv.link_visits + 1) if rmv.volunteer.user == current_user
    end
  end

  def edit; end

  def create
    @trial_feedback = TrialFeedback.new(trial_feedback_params.merge(author_id: current_user.id,
      volunteer_id: @volunteer.id, reviewer_id: current_user.superadmin? ? current_user.id : nil))
    @trial_feedback.trial_feedbackable = @trial_feedbackable
    authorize @trial_feedback
    if @trial_feedback.save
      redirect_to @trial_feedback.volunteer, make_notice
    else
      render :new
    end
  end

  def update
    if @trial_feedback.update(trial_feedback_params
        .merge(reviewer_id: current_user.superadmin? ? current_user.id : nil))
      update_redirect
    else
      render :edit
    end
  end

  def destroy
    @trial_feedback.destroy
    redirect_back(fallback_location: url_for(@trial_feedbackable))
  end

  def need_review
    authorize TrialFeedback
    @need_review = TrialFeedback.need_review
  end

  def mark_as_done
    if @trial_feedback.update(marked_done_by: current_user)
      redirect_to list_responses_trial_feedbacks_path,
        notice: 'Probezeit Feedback als erledigt markiert.'
    else
      redirect_to list_responses_trial_feedbacks_path,
        notice: 'Fehler: Erledigt markieren fehlgeschlagen.'
    end
  end

  private

  def set_trial_feedbackable
    return @trial_feedbackable = Assignment.find(params[:assignment_id]) if params[:assignment_id]
    @trial_feedbackable = GroupOffer.find(params[:group_offer_id]) if params[:group_offer_id]
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
  end

  def set_trial_feedback
    @trial_feedback = TrialFeedback.find(params[:id])
    @trial_feedbackable = @trial_feedback.trial_feedbackable
    @volunteer = @trial_feedback.volunteer
    authorize @trial_feedback
  end

  def update_notice
    if current_user.superadmin?
      'Probezeit Feedback quittiert.'
    else
      'Probezeit Feedback wurde erfolgreich geändert.'
    end
  end

  def update_redirect
    if request.referer.include?('need_review')
      redirect_to need_review_volunteers_path, notice: 'Probezeit Feedback quittiert.'
    else
      redirect_to @trial_feedback.volunteer, notice: update_notice
    end
  end

  def trial_feedback_params
    params.require(:trial_feedback).permit(:body, :volunteer_id, :group_offer_id, :assignment_id,
      :trial_feedbackable_id)
  end
end
