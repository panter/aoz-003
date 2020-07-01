module SemesterScopesGenerators
  def hour_for_meeting_date(meeting_date, hourable, hours = 1.0)
    before = Time.zone.now
    travel_to meeting_date
    create :hour, volunteer: hourable.volunteer, hours: hours.to_f, meeting_date: meeting_date,
      hourable: hourable.polymorph_url_object
    travel_to before
  end
end
