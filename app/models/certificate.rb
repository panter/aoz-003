class Certificate < ApplicationRecord
  belongs_to :volunteer
  belongs_to :user, -> { with_deleted }

  def build_values
    self.assignment_kinds ||= { done: volunteer.assignment_categories_done,
                                available: volunteer.assignment_categories_available }
    self.text_body ||= default_text_body
    self.function ||= DEFAULT_FUNCTION
    self.hours ||= volunteer.hours.total_hours
    self.volunteer_contact ||= convert_volunteer_contact
    self.institution ||= DEFAULT_INSTITUTION + ", #{user&.profile.contact.primary_phone}"
    self.duration_start = volunteer.min_assignment_date
    self.duration_end = volunteer.max_assignment_date
    self.creator_name ||= user.profile.contact.full_name
    self.creator_function ||= user.profile.profession
  end

  def convert_volunteer_contact
    {
      name: volunteer.contact.full_name,
      street: volunteer.contact.full_street,
      city: volunteer.contact.full_city
    }
  end

  def collection_for_additional_kinds
    assignment_kinds['available'] - assignment_kinds['done']
  end

  DEFAULT_INSTITUTION = "**AOZ** Zürich, Flüelastrasse 32, 8047 Zürich  \r\n"\
    'info@aoz-freiwillige.ch'.freeze

  DEFAULT_FUNCTION = 'Förderung der sozialen und beruflichen Integration von Asylsuchenden, '\
    'Geflüchteten und Migrant/innen'.freeze

  def default_text_body
    <<~HEREDOC
      Die **AOZ** ist ein Unternehmen der Stadt Zürich und mit über 1000
      Mitarbeitenden seit vielen Jahren im Auftrag des Bundes, des Kantons, der Stadt und weiterer
      Gemeinden im Migrations- und Integrations bereich tätig.

      Die Fachstelle Freiwilligenarbeit vermittelt Kontakte zwischen Asylsuchenden, Flüchtlingen und Migrant/innen
      (Begleitete) mit Menschen, die schon länger in der Schweiz leben und sehr gut Deutsch
      sprechen (Freiwillige). Durch wöchentliche Besuche bei den Begleiteten zuhause während
      mindestens sechs Monaten oder im Gruppenunterricht fördern die Freiwilligen gezielt und konkret die
      soziale und Berufliche Integration der Begleiteten. Dadurch ergänzen sie die Sozialberatung
      auf sinvolle Weise. Das durch die Fachstelle Freiwilligenarbeit angebotene Weiterbildungsprogramm (Einführungskurs,
      Erfahrungsaustausch, Fachveranstaltungen) bietet den Freiwillgen die Gelegenheit sich
      vertiefter mit Fragen zu Asylverfahren und Integration auseinanderzusetzen.

      ***Individuellen Text hier einfügen***
    HEREDOC
  end
end
