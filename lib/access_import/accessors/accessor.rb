require 'access_import/acc_utils'
require 'ostruct'

class Accessor
  include AccUtils

  def initialize(acdb, *other_accessors)
    add_other_accessors(*other_accessors) if other_accessors.any?
    @acdb = acdb
  end

  def add_other_accessors(*accessors)
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def all
    @all ||= hash_all
  end

  def find(id)
    all[id.to_i]
  end

  ACCESS_ROLES = OpenStruct.new(volunteer: 1, client: 2, animator: 3, participant: 4).freeze

  EINSATZ_ROLLEN = OpenStruct.new(freiwillige: 1, begleitete: 2, animator: 3, teilnehmende: 4)


  FREIWILLIGEN_FUNKTION_BY_NAME = OpenStruct.new(
    begleitung: OpenStruct.new(id: 1, bezeichnung: 'Begleitung', rolle: 'Freiwillige/r'),
    kurs: OpenStruct.new(id: 2, bezeichnung: 'Kurs', rolle: 'Freiwillige/r'),
    animation_f: OpenStruct.new(id: 3, bezeichnung: 'Animation F', rolle: 'Freiwillige/r'),
    kurzeinsatz: OpenStruct.new(id: 4, bezeichnung: 'Kurzeinsatz', rolle: 'Freiwillige/r'),
    andere: OpenStruct.new(id: 5, bezeichnung: 'Andere', rolle: 'Freiwillige/r'),
    animation_a: OpenStruct.new(id: 6, bezeichnung: 'Animation A', rolle: 'Animator/in')
  ).freeze

  def freiwilligen_funktion(id)
    FREIWILLIGEN_FUNKTION_BY_NAME.to_h.find { |funktion| funktion[1].id == id }.last
  end

  SEMESTER = {
    1 => { semester: 'Frühling / Sommer', rolle: 'Animator/in' },
    2 => { semester: 'Herbst / Winter', rolle: 'Animator/in' },
    3 => { semester: '1. Halbjahr', rolle: 'Freiwillige/r' },
    4 => { semester: '2. Halbjahr', rolle: 'Freiwillige/r' }
  }.freeze

  LEHRMITTEL = {
    1 => 'ABC 1 - Alphabetisierung für Erwachsene',
    2 => 'ABC 2 - Alphabetisierung für Erwachsene',
    3 => 'Vorstufe Deutsch 1',
    4 => 'Vorstufe Deutsch 2'
  }.freeze

  AUSBILDUNGS_TYPEN = {
    1 => '<keine>',
    2 => 'Primarschule',
    3 => 'Sekundarschule',
    4 => 'Fachmittelschule',
    5 => 'Fahhochschule',
    6 => 'Gymnasium',
    7 => 'GEP-Einsatz',
    8 => 'EBA Eidg. Berufsattest',
    9 => 'eidg. Anerkannte Berufslehre'
  }.freeze

  JOURNAL_KATEGORIEN = {
    1 => 'Telefonat',
    2 => 'Gespräch',
    3 => 'E-Mail',
    4 => 'Rückmeldung',
    5 => 'Datei'
  }.freeze
end
