class Accessor
  include AccUtils
  attr_reader :records

  def initialize(acdb)
    @acdb = acdb
    @records = hash_all
  end

  def all
    @records
  end

  def find(id)
    @records[id.to_i]
  end

  SEMESTER = [
    [1, { semester: 'Frühling / Sommer', rolle: 'Animator/in' }],
    [2, { semester: 'Herbst / Winter', rolle: 'Animator/in' }],
    [3, { semester: '1. Halbjahr', rolle: 'Freiwillige/r' }],
    [4, { semester: '2. Halbjahr', rolle: 'Freiwillige/r' }]
  ].to_h.freeze

  FREIWILLIGEN_FUNKTIONEN = [
    nil,
    'Begleitung',
    'Kurs',
    'Animation F',
    'Kurzeinsatz',
    'Andere',
    'Animation A'
  ].freeze

  LEHRMITTEL = [
    nil,
    'ABC 1 - Alphabetisierung für Erwachsene',
    'ABC 2 - Alphabetisierung für Erwachsene',
    'Vorstufe Deutsch 1',
    'Vorstufe Deutsch 2'
  ].freeze

  AUSBILDUNGS_TYPEN = [
    nil,
    '<keine>',
    'Primarschule',
    'Sekundarschule',
    'Fachmittelschule',
    'Fahhochschule',
    'Gymnasium',
    'GEP-Einsatz',
    'EBA Eidg. Berufsattest',
    'eidg. Anerkannte Berufslehre'
  ].freeze

  JOURNAL_KATEGORIEN = [
    nil,
    'Telefonat',
    'Gespräch',
    'E-Mail',
    'Rückmeldung',
    'Datei'
  ].freeze
end
