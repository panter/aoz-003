class Certificate < ApplicationRecord
  belongs_to :volunteer
  belongs_to :user, -> { with_deleted }

  def build_values
    return unless text_body.nil?
    self.text_body ||= default_text_body
    self.function ||= DEFAULT_FUNCTION
    self.hours ||= volunteer.hours.total_hours
    self.minutes ||= volunteer.hours.minutes_rest
    self.assignment_kinds ||= volunteer.assignment_kinds
    self.volunteer_contact ||= convert_volunteer_contact
    self.institution ||= DEFAULT_INSTITUTION
    self.group_offer ||= has_group_offer
  end

  def has_group_offer
    true unless volunteer.group_offers.nil?
  end

  def convert_volunteer_contact
    {
      name: volunteer.contact.full_name,
      street: volunteer.contact.full_street,
      city: volunteer.contact.full_city
    }
  end

  def assignment_kinds=(value)
    super(value.to_h.map do |key, bool|
      bool = bool.to_i == 1 if bool.is_a? String
      [key.to_sym, bool]
    end.to_h)
  end

  DEFAULT_INSTITUTION = "**AOZ** Zürich, Flüelastrasse 32, 8047 Zürich  \r\n"\
    '044 415 67 35, info@aoz-freiwillige.ch'.freeze

  DEFAULT_FUNCTION = 'Förderung der sozialen und beruflichen Integration von Asylsuchenden, '\
    'Geflüchteten und Migrant/innen'.freeze

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
