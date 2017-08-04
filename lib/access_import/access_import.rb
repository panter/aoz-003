class AccessImport
  attr_reader :acdb

  def initialize(path)
    @acdb = Mdb.open(path)
    class_accessor(*[Laender, Sprachen, SprachKenntnisse, PersonenRolle, Plz, FamilienRollen,
                     Begleitete, KostenTraeger, Journale, FallstelleTeilnehmer, Stundenerfassung, Ausbildungen,
                     FreiwilligenEinsaetze, FreiwilligenEntschaedigung, Kontoangaben].map { |cl| cl.new(@acdb) })
    class_accessor(SpracheProHauptperson.new(@acdb, @sprachen, @sprach_kenntnisse),
      EinsatzOrte.new(@acdb, @plz))
    class_accessor(HauptPerson.new(@acdb, @plz, @laender, @sprache_pro_hauptperson))
  end

  def make_clients
    client_transformer = ClientTransform.new(@begleitete, @haupt_person, @familien_rollen)
    client_count_before = Client.count
    @personen_rolle.all_clients.each do |key, ac_client|
      next if Import.where(
        importable_type: 'Client', access_id: ac_client[:pk_PersonenRolle].to_i
      ).any?
      client_attrs = client_transformer.prepare_attributes(ac_client)
      client = Client.new(client_attrs)
      client.created_at = ac_client[:d_Rollenbeginn]
      client.updated_at = ac_client[:d_MutDatum]
      client.user = User.first
      puts "Importing personen_rolle #{key} to Client.id: #{client.id}" if client.save!
    end
    puts "Imported #{Client.count - client_count_before} new clients from MS Access Database."
  end

  def make_volunteers
    volunteer_transformer = VolunteerTransform.new(@haupt_person)
    count_before_import = Volunteer.count
    @personen_rolle.all_volunteers.each do |key, ac_volunteer|
      next if Import.where(
        importable_type: 'Volunteer', access_id: ac_volunteer[:pk_PersonenRolle].to_i
      ).any?
      volunteer_attrs = volunteer_transformer.prepare_attributes(ac_volunteer)
      volunteer = Volunteer.new(volunteer_attrs)
      volunteer.created_at = ac_volunteer[:d_Rollenbeginn]
      volunteer.updated_at = ac_volunteer[:d_MutDatum]
      puts "Importing personen_rolle #{key} to Volunteer.id: #{volunteer.id}" if volunteer.save!
    end
    puts "Imported #{Volunteer.count - count_before_import} new volunteers from MS Access Datbase."
  end

  def class_accessor(*accessors)
    accessors.each do |accessor|
      class_eval { attr_reader accessor.class.name.underscore.to_sym }
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end
end
