class ListResponsesController < ApplicationController
  def feedbacks
    authorize :list_response
    @q = Feedback.created_asc.author_volunteer(params[:q]).ransack(params[:q])
    @q.sorts = ['updated_at asc'] if @q.sorts.empty?
    @feedbacks = @q.result.paginate(page: params[:page])
  end

  def trial_feedbacks
    authorize :list_response
    @q = TrialFeedback.created_asc.author_volunteer(params[:q]).ransack(params[:q])
    @q.sorts = ['updated_at asc'] if @q.sorts.empty?
    @trial_feedbacks = @q.result.paginate(page: params[:page])
  end

  def hours
    authorize :list_response
    @q = Hour.created_asc.ransack(params[:q])
    @q.sorts = ['updated_at asc'] if @q.sorts.empty?
    @hours = @q.result.paginate(page: params[:page])
  end
end
