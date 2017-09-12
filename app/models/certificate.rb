class Certificate < ApplicationRecord
  after_initialize :build_values

  belongs_to :volunteer
  belongs_to :user

  def build_values
    return unless text_body.nil?
    update(text_body: default_text_body, function: default_function,
      assignment_kinds: volunteer.assignment_kinds, volunteer_contact: convert_volunteer_contact,
      hours: volunteer.hours.sum(:hours) + (volunteer.hours.sum(:minutes) / 60),
      minutes: volunteer.hours.sum(:minutes) % 60, institution: default_institution)
    update(volunteer.assignments_duration)
  end

  def convert_volunteer_contact
    {
      name: volunteer.contact.slice(:first_name, :last_name).values.join(' '),
      street: volunteer.contact.slice(:street, :extended).values.join(', '),
      city: volunteer.contact.slice(:postal_code, :city).values.join(' ')
    }
  end

  def assignment_kinds=(value)
    super(value.to_h.map do |key, bool|
      bool = bool.to_i == 1 if bool.is_a? String
      [key.to_sym, bool]
    end.to_h)
  end

  def default_institution
    <<~HEREDOC
      **AOZ** Zürich, Flüelastrasse 32, 8047 Zürich<br>
      044 415 67 35, info@aoz-freiwillige.ch
    HEREDOC
  end

  def default_function
    <<~HEREDOC
      Förderung der sozialen und beruflichen Integration von Asylsuchenden, Geflüchteten und Migrant/innen
    HEREDOC
  end

  def default_text_body
    <<~HEREDOC
      Die **AOZ** ist ein Unternehmen der Stadt Zürich und mit über 1000
      Mitarbeitenden seit vielen Jahren im Auftrag des Bundes, des Kantons, der Stadt und weiterer
      Gemeinden im Migrations- und Integrations bereich tätig.

      TransFair vermittelt Kontakte zwischen Asylsuchenden, Flüchtlingen und Migrant/innen
      (Begleitete) mit Menschen, die schon länger in der Schweiz leben und sehr gut Deutsch
      sprechen (Freiwillige). Durch wöchentliche Besuche bei den Begleiteten zuhause während
      mindestens sechs Monaten oder im Gruppenunterricht fördern die Freiwilligen gezielt und konkret die
      soziale und Berufliche Integration der Begleiteten. Dadurch ergänzen sie die Sozialberatung
      auf sinvolle Weise. Das von TransFair angebotene Weiterbildungsprogramm (Einführungskurs,
      Erfahrungsaustausch, Fachveranstaltungen) bietet den Freiwillgen die Gelegenheit sich
      vertiefter mit Fragen zu Asylverfahren und Integration auseinanderzusetzen.

      ***Individuellen Text hier einfügen***
    HEREDOC
  end
end
