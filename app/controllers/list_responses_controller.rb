class ListResponsesController < ApplicationController
  def feedbacks
    authorize :list_response
    if params[:q].to_unsafe_hash.except(:s).blank?
      params[:q] = params[:q].to_unsafe_hash.merge('marked_done_by_id_null': 'true')
    end
    @q = Feedback.created_asc.author_volunteer.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @feedbacks = @q.result.paginate(page: params[:page])
  end

  def trial_feedbacks
    authorize :list_response
    @q = TrialFeedback.created_asc.author_volunteer.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @trial_feedbacks = @q.result.paginate(page: params[:page])
  end

  def hours
    authorize :list_response
    @q = Hour.created_asc.not_marked_done.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @hours = @q.result.paginate(page: params[:page])
  end
end
