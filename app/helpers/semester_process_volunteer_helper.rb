module SemesterProcessVolunteerHelper
  def initialize_feedback
    @feedback = SemesterFeedback.new(mission: @mission, semester_process_volunteer: @semester_process_volunteer,
      author: current_user)
  end

  def set_reviewed
    @semester_process_volunteer.commited_by = current_user
    @semester_process_volunteer.commited_at = Time.zone.now
  end

  def assign_volunteer_attributes
    @volunteer.assign_attributes(review_params[:volunteer_attributes]
      .slice(:waive, :bank, :iban))
  end

  def null_reviewed
    @semester_process_volunteer.commited_by = nil
    @semester_process_volunteer.commited_at = nil
  end

  def render_missions(spv)
    html = ""
    spv.missions.each do |m|
      html += link_to m.to_label, "/#{m.class.name.underscore.pluralize}/#{m.id}/edit", target: '_blank'
      html += "<br>"
    end
    html.html_safe
  end
end
