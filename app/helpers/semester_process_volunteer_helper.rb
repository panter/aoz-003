module SemesterProcessVolunteerHelper
  def render_missions(spv)
    html = ""
    spv.missions.each do |m|
      html += link_to m.to_label, "/#{m.class.name.underscore.pluralize}/#{m.id}/edit", target: '_blank'
      html += "<br>"
    end
    html.html_safe
  end
end
