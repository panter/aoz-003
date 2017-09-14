require 'securerandom'

class AccessImport
  attr_reader :acdb

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
    transformer = DepartmentTransform.new
    @einsatz_orte.all.each do |key, einsatz_ort|
      next if Import.exists?(importable_type: 'Department', access_id: key)
      parameters = transformer.prepare_attributes(einsatz_ort)
      department = Department.new(parameters)
      department.updated_at = einsatz_ort[:d_MutDatum]
      department.save!
    end
  end

  def make_clients
    transformer = ClientTransform.new(@begleitete, @haupt_person, @familien_rollen)
    make_personen_rolle(@personen_rolle.all_clients, transformer, Client) do |client, personen_rolle|
      client = personen_rollen_create_update_conversion(client, personen_rolle)
      client.user_id = @import_user.id
      client.state = handle_client_state(personen_rolle)
    end
  end

  def handle_client_state(personen_rolle)
    if personen_rolle[:d_Rollenende]
      Client::FINISHED
    elsif personen_rolle[:d_Rollenende].nil?
      Client::ACTIVE
    else
      Client::REGISTERED
    end
  end

  def make_volunteers
    transformer = VolunteerTransform.new(@haupt_person)
    make_personen_rolle(@personen_rolle.all_volunteers, transformer, Volunteer) do |volunteer, personen_rolle|
      volunteer = personen_rollen_create_update_conversion(volunteer, personen_rolle)
      volunteer.registrar_id = @import_user.id
      volunteer.state = handle_volunteer_state(personen_rolle)
    end
  end

  def handle_volunteer_state(personen_rolle)
    return Volunteer::RESIGNED if personen_rolle[:d_Rollenende]
    return Volunteer::ACTIVE if personen_rolle[:d_Rollenende].nil?
    Volunteer::REGISTERED
  end

  def make_assignments
    transformer = AssignmentTransform.new(@begleitete)
    records_before = Assignment.count
    @freiwilligen_einsaetze.where_volunteer.each do |key, fw_einsatz|
      next if Import.exists?(importable_type: 'Assignment', access_id: key)
      volunteer = Import.get_imported(Volunteer, fw_einsatz[:fk_PersonenRolle])
      next if volunteer.state == Volunteer::RESIGNED
      begleitet = @begleitete.find(fw_einsatz[:fk_Begleitete])
      client = Import.get_imported(Client, begleitet[:fk_PersonenRolle])
      next if client.state == Client::FINISHED
      parameters = transformer.prepare_attributes(fw_einsatz, client, volunteer, begleitet)
      assignment = Assignment.new(parameters)
      assignment.created_at = fw_einsatz[:d_EinsatzVon] || Time.zone.now
      assignment.creator_id = @import_user.id
      assignment.save!
      puts format('-- Access Assignment %d imported to Assignment.id %d', key, assignment.id)
    end
    puts format('Imported %d new Assignments from MS Access Database.',
      Assignment.count - records_before)
  end

  def make_journal
    transformer = JournalTransform.new
    records_before = Journal.count
    @journale.all.each do |key, acc_journal|
      next if Import.exists?(importable_type: 'Journal', access_id: key)
      person_import = Import.find_by_hauptperson(acc_journal[:fk_Hauptperson])
      next unless person_import
      person = person_import&.importable
      if acc_journal[:fk_FreiwilligenEinsatz]&.positive?
        assignment = Import.get_imported(Assignment, acc_journal[:fk_FreiwilligenEinsatz])
      end
      local_journal = Journal.new(transformer.prepare_attributes(acc_journal, person, assignment,
        @import_user))
      local_journal.save!
      puts format('Imported Access Journal %d to Journal.id %d', key, local_journal.id)
    end
    puts format('Imported %d new %s from MS Access Database.',
      Assignment.count - records_before, Assignment.name)
  end

  def personen_rollen_create_update_conversion(model_record, personen_rolle)
    model_record.created_at = personen_rolle[:d_Rollenbeginn]
    model_record.updated_at = personen_rolle[:d_MutDatum]
    model_record
  end

  def make_personen_rolle(base_entities, transformer, destination_model)
    records_before = destination_model.count
    base_entities.each do |key, entity|
      next if Import.exists?(importable_type: destination_model.to_s, access_id: key)
      parameters = transformer.prepare_attributes(entity)
      import_record = destination_model.new(parameters)
      handler_message = yield(import_record, entity)
      import_record.save!
      puts format('Importing personen_rolle %d to %s.id %d  %s', key, destination_model,
        import_record.id, handler_message)
    end
    puts format('Imported %d new %s from MS Access Database.',
      destination_model.count - records_before, destination_model.name.pluralize)
  end

  def instantiate_all_accessors
    Dir['lib/access_import/accessors/*.rb']
      .map { |file| File.basename(file, '.*') }
      .reject { |name| name == 'accessor' }
      .map do |name|
        name.camelize.constantize.new(@acdb)
      end
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
    password = SecureRandom.hex(60)
    import_user = User.new(role: 'superadmin', password: password, email: EMAIL)
    import_user.build_profile
    import_user.profile.contact.first_name = 'AOZ Import'
    import_user.profile.contact.last_name = 'AOZ Import'
    import_user.profile.contact.primary_email = EMAIL
    import_user.save
    import_user
  end

  def self.finalize
    proc { User.find_by(email: EMAIL).delete }
  end
end
