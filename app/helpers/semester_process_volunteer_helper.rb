module SemesterProcessVolunteerHelper
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

  def set_semester_process_volunteer
    @spv = SemesterProcessVolunteer.find(params[:id])
    authorize @spv
    @semester_process = @spv.semester_process
    @volunteer = @spv.volunteer
  end
end
