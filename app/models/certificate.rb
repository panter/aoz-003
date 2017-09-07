class Certificate < ApplicationRecord
  after_initialize :build_values

  belongs_to :volunteer
  belongs_to :user

  def build_values
    return unless text_body.nil?
    update(text_body: DEFAULT_TEXT_BODY, funktion: DEFAULT_FUNKTION,
      assignment_kinds: volunteer.assignment_kinds,
      hours: volunteer.hours.sum(:hours) + (volunteer.hours.sum(:minutes) / 60),
      minutes: volunteer.hours.sum(:minutes) % 60)
    update(volunteer.assignments_duration)
  end

  DEFAULT_FUNKTION = 'Förderung der sozialen und beruflichen Integration von Asylsuchenden, '\
    'Geflüchteten und Migrant/innen'.freeze
  DEFAULT_TEXT_BODY = 'Die AOZ ist ein Unternehmen der Stadt Zürich und mit über 1000 '\
    'Mitarbeitenden seit vielen Jahren im Auftrag des Bundes, des Kantons, der Stadt und weiterer '\
    'Gemeinden im Migrations- und Integrations bereich tätig.' + "\n\n"\
    'TransFair vermittelt Kontakte zwischen Asylsuchenden, Flüchtlingen und '\
    'Migrant/innen (Begleitete) mit Menschen, die schon länger in der Schweiz leben'\
    ' und sehr gut Deutsch sprechen (Freiwillige). Durch wöchentliche Besuche bei '\
    'den Begleiteten zuhause während mindestens sechs Monaten oder im '\
    'Gruppenunterricht fördern die Freiwilligen gezielt und konkret die soziale und '\
    'Berufliche Integration der Begleiteten. Dadurch ergänzen sie die Sozialberatung '\
    'auf sinvolle Weise. Das von TransFair angebotene Weiterbildungsprogramm '\
    '(Einführungskurs, Erfahrungsaustausch, Fachveranstaltungen) bietet den '\
    'Freiwillgen die Gelegenheit sich vertiefter mit Fragen zu Asylverfahren und '\
    'Integration auseinanderzusetzen.' + "\n\n".freeze
end
