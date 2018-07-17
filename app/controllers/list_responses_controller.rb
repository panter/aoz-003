class ListResponsesController < ApplicationController
  before_action { set_default_filter(author_volunteer: 'true', reviewer_id_null: 'true') }

  def feedbacks
    authorize :list_response
    @q = Feedback.created_asc.author_volunteer(params[:q]).ransack(params[:q])
    @q.sorts = ['updated_at asc'] if @q.sorts.empty?
    @feedbacks = @q.result.paginate(page: params[:page])
    set_responsibles
  end

  def trial_feedbacks
    authorize :list_response
    @q = TrialFeedback.created_asc.author_volunteer(params[:q]).ransack(params[:q])
    @q.sorts = ['updated_at asc'] if @q.sorts.empty?
    @trial_feedbacks = @q.result.paginate(page: params[:page])
  end

  private

  def set_responsibles
    @responsibles = Feedback.joins(responsible: [profile: [:contact]])
      .distinct
      .select('users.id, contacts.full_name')
      .map do |responsible|
        {
          q: :responsible_id_eq,
          text: "Übernommen von #{responsible.full_name}",
          value: responsible.id
        }
      end
  end
end
