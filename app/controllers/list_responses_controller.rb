class ListResponsesController < ApplicationController
  before_action { set_default_filter(author_volunteer: 'true', reviewer_id_null: 'true') }

  def trial_feedbacks
    authorize :list_response
    @q = TrialFeedback.created_asc.author_volunteer(params[:q]).ransack(params[:q])
    @q.sorts = ['updated_at asc'] if @q.sorts.empty?
    @trial_feedbacks = @q.result.paginate(page: params[:page])
  end
end
