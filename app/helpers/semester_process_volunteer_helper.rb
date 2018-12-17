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
        @nested_objects[spv_mission.id.to_s][:hours] = Hour.new(hash[:hour].merge({
          volunteer: spv_mission.volunteer,
          meeting_date: spv_mission.semester_process_volunteer.semester.last.to_date,
          hourable: spv_mission.mission.group_assignment? ? spv_mission.mission.group_offer : spv_mission.mission
        }))
      end
    end
  end

  def create_journals
    spv = SemesterProcessVolunteer.find(params[:id])
    return unless spv.commited_at?
    volunteer = spv.volunteer
    semester_feedbacks = spv.semester_feedbacks
    Journal.create(user: volunteer.user, journalable: volunteer,
      category: :feedback, title: "Semester Prozess Feedback vom #{I18n.l(Time.zone.today)}: ",
      body: render_semester_feedbacks(semester_feedbacks))
  end

  def render_semester_feedbacks(semester_feedbacks)
    text = ''
    semester_feedbacks.each do |semester_feedback|
      text += semester_feedback.mission.to_label
      text += "\n\n"
      text += semester_feedback.slice(:goals, :achievements, :future, :comments).map do |key, sfb_quote|
                "#{I18n.t("activerecord.attributes.feedback.#{key}")}:\n«#{sfb_quote}»" if sfb_quote.present?
              end.compact.join("\n\n")
      text += "\n\n"
    end
    text
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

  def set_responsibles
    @responsibles = SemesterProcessVolunteer.joins(responsible: [profile: [:contact]])
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

  def set_reviewers
    @reviewers = SemesterProcessVolunteer.joins(reviewed_by: [profile: [:contact]])
      .distinct
      .select('users.id, contacts.full_name')
      .map do |reviewed_by|
        {
          q: :reviewed_by_id_eq,
          text: "Quittiert von #{reviewed_by.full_name}",
          value: reviewed_by.id
        }
      end
  end

  def prepare_review
    @semester_process_volunteer = SemesterProcessVolunteer.find(params[:id])
    authorize @semester_process_volunteer
    @volunteer = @semester_process_volunteer.volunteer
    @missions = @semester_process_volunteer.missions
  end

  def set_semester_process_volunteer
    @spv = SemesterProcessVolunteer.find(params[:id])
    authorize @spv
    @semester_process = @spv.semester_process
    @volunteer = @spv.volunteer
  end

  def save_feedback_data!
    @semester_process_volunteer.volunteer.validate_waive_and_bank = true

    ActiveRecord::Base.transaction do
      @semester_process_volunteer.save!
      @volunteer.save!

      @nested_objects.each do |_key, hash|
        hash.each { |_id, obj| obj.save! }
      end
    end
    true
  rescue ActiveRecord::RecordInvalid => exception
    null_reviewed
    flash[:alert] = exception.message
    false
  end
end
