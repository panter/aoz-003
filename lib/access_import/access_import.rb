require 'securerandom'

class AccessImport
  attr_reader :acdb
  attr_reader :import_user

  EMAIL = 'aoz_access_importer@example.com'.freeze

  def initialize(path)
    ObjectSpace.define_finalizer(self, self.class.finalize)
    @import_user = create_or_fetch_import_user
    @acdb = Mdb.open(path)
    make_class_variables(*instantiate_all_accessors)
    @sprache_pro_hauptperson.add_other_accessors(@sprachen, @sprach_kenntnisse)
    @einsatz_orte.add_other_accessors(@plz)
    @haupt_person.add_other_accessors(@plz, @laender, @sprache_pro_hauptperson)
  end

  def make_departments
    @einsatz_orte.all.each do |key, einsatz_ort|
      next if Import.exists?(importable_type: 'Department', access_id: key)
      parameters = department_transform.prepare_attributes(einsatz_ort)
      department = Department.new(parameters)
      department.updated_at = einsatz_ort[:d_MutDatum]
      department.save!
    end
  end

  def make_clients
    @client_transformer.import_all
  end

  def make_volunteers
    @volunteer_transform.import_all
  end

  def make_assignments
    records_before = Assignment.count
    @freiwilligen_einsaetze.where_begleitung.each do |key, fw_einsatz|
      next if Import.exists?(importable_type: 'Assignment', access_id: key)
      volunteer = volunteer_transform.get_or_create_by_import(fw_einsatz[:fk_PersonenRolle])
      # volunteer = Import.get_imported(Volunteer, fw_einsatz[:fk_PersonenRolle])
      begleitet = @begleitete.find(fw_einsatz[:fk_Begleitete])
      client = client_transform.get_or_create_by_import(begleitet[:fk_PersonenRolle])
      # client = Import.get_imported(Client, begleitet[:fk_PersonenRolle])
      parameters = assignment_transform.prepare_attributes(fw_einsatz, client, volunteer, begleitet)
      assignment = Assignment.new(parameters)
      assignment.created_at = fw_einsatz[:d_EinsatzVon] || Time.zone.now
      assignment.save!
      assignment.delete if assignment.period_end.present? && assignment.period_end < 8.months.ago
      puts format('-- Access Assignment %d imported to Assignment.id %d', key, assignment.id)
    end
    puts format('Imported %d new Assignments from MS Access Database.',
      Assignment.count - records_before)
  end

  def make_group_offers
    kurs_transform.import_all
  end

  def make_journal
    records_before = Journal.count
    @journale.all.each do |key, acc_journal|
      next if Import.exists?(importable_type: 'Journal', access_id: key)
      person_import = Import.find_by_hauptperson(acc_journal[:fk_Hauptperson])
      next unless person_import
      person = person_import&.importable
      if acc_journal[:fk_FreiwilligenEinsatz]&.positive?
        assignment = Import.get_imported(Assignment, acc_journal[:fk_FreiwilligenEinsatz])
      end
      local_journal = Journal.new(journal_transform.prepare_attributes(acc_journal, person, assignment))
      local_journal.save!
      puts format('Imported Access Journal %d to Journal.id %d', key, local_journal.id)
    end
    puts format('Imported %d new %s from MS Access Database.',
      Assignment.count - records_before, Assignment.name)
  end

  def instantiate_all_accessors
    Dir['lib/access_import/accessors/*.rb']
      .map { |file| File.basename(file, '.*') }
      .reject { |name| name == 'accessor' }
      .map do |name|
        name.camelize.constantize.new(@acdb)
      end
  end

  def assignment_transform
    @assignment_transform ||= AssignmentTransform.new(self, @begleitete)
  end

  def client_transform
    @client_transform ||= ClientTransform.new(self, @begleitete, @haupt_person, @familien_rollen,
      @personen_rolle)
  end

  def department_transform
    @department_transform ||= DepartmentTransform.new(self)
  end

  def einsatz_transform
    @einsatz_transform ||= EinsatzTransform.new(self, @freiwilligen_einsaetze, @personen_rolle)
  end

  def group_assignment_transform
    @group_assignment_transform ||= GroupAssignmentTransform.new(self, @begleitete,
      @freiwilligen_einsaetze, @personen_rolle, @haupt_person)
  end

  def journal_transform
    @journal_transform ||= JournalTransform.new(self)
  end

  def kurs_transform
    @kurs_transform ||= KursTransform.new(self, @kurse, @begleitete, @haupt_person, @familien_rollen,
      @personen_rolle, @kursarten, @freiwilligen_einsaetze, @einsatz_orte)
  end

  def kursart_transform
    @kursart_transform ||= KursartTransform.new(self, @kursarten)
  end

  def volunteer_transform
    @volunteer_transform ||= VolunteerTransform.new(self, @haupt_person, @personen_rolle)
  end

  def make_class_variables(*accessors)
    accessors.each do |accessor|
      class_eval { attr_reader accessor.class.name.underscore.to_sym }
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def create_or_fetch_import_user
    return User.find_by(email: EMAIL) if User.exists?(email: EMAIL)
    return User.deleted.find_by(email: EMAIL).restore if User.deleted.exists?(email: EMAIL)
    import_user = FactoryBot.create :user, email: EMAIL, password: SecureRandom.hex(60)
    import_user.profile.contact.first_name = 'AOZ Import'
    import_user.profile.contact.last_name = 'AOZ Import'
    import_user.profile.contact.primary_email = EMAIL
    import_user.save!
    import_user
  end

  def self.finalize
    proc { User.find_by(email: EMAIL).delete }
  end
end
