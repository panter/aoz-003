class ReviewSemestersController < ApplicationController
  before_action :prepare_review, :initialize_nested_objects, only: [:review_semester, :submit_review]

  include ReviewSemesterHelper

  def review_semester; end

  def submit_review
    # you shall not pass
    return if @semester_process_volunteer.commited_at

    set_reviewed
    assign_volunteer_attributes
    build_nested_objects

    if save_feedback_data!
      create_journals
      redirect_to review_semester_review_semester_url(@semester_process_volunteer), notice: t('.success')
    else
      render :review_semester
    end
  end
end