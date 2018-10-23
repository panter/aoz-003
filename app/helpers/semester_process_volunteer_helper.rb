module SemesterProcessVolunteerHelper
  def initialize_feedback
    @feedback = SemesterFeedback.new(mission: @mission, semester_process_volunteer: @semester_process_volunteer,
      author: current_user)
  end

  def set_reviewed
    @semester_process_volunteer.commited_by = current_user
    @semester_process_volunteer.commited_at = Time.zone.now
  end

  def assign_reviewed_attributes
    @hour = Hour.new(
      volunteer: @volunteer,
      hourable: @mission,
      semester_process_volunteer: @semester_process_volunteer,
      meeting_date: Time.zone.now,
    )
    @hour.assign_attributes(review_params[:hour])
    @volunteer.assign_attributes(review_params[:volunteer_attributes]
      .slice(:waive, :bank, :iban))
    @feedback.assign_attributes(review_params[:semester_feedback])
  end

  def null_reviewed
    @semester_process_volunteer.commited_by = nil
    @semester_process_volunteer.commited_at = nil
  end
end
