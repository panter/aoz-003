module SemesterProcessVolunteerHelper

  def set_reviewed
    @semester_process_volunteer.commited_by = current_user
    @semester_process_volunteer.commited_at = Time.zone.now
  end

  def initialize_nested_objects
    @nested_objects = {}
    @semester_process_volunteer.semester_process_volunteer_missions.each do |spvm|
      @nested_objects[spvm.id.to_s] = { feedback: @semester_process_volunteer.semester_feedback_with_mission(spvm.mission) || SemesterFeedback.new }
    end
    @nested_objects
  end

  def build_nested_objects
    review_params[:semester_feedbacks_attributes].each do |_key, hash|
      spv_mission = SemesterProcessVolunteerMission.find(hash[:semester_feedback][:spv_mission_id])
      @nested_objects[spv_mission.id.to_s][:feedback] = SemesterFeedback.new(hash[:semester_feedback].merge({
          author: current_user, semester_process_volunteer: @semester_process_volunteer
      }))

      if hash[:hour][:hours].to_i.positive?
        @nested_objects[spv_mission.id.to_s][:hours] =  Hour.new(hash[:hour].merge({
              volunteer: spv_mission.volunteer,
              meeting_date: Time.zone.now,
              hourable: spv_mission.mission.group_assignment? ? spv_mission.mission.group_offer : spv_mission.mission
        }))
      end
    end
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
