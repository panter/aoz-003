require_all 'lib/access_import'

class AccessImport
  attr_reader :acdb, :begleitete, :haupt_personen, :personen_rollen, :familien_rollen
  attr_reader :laender, :sprachen, :sprach_kenntnisse, :sprache_hauptperson, :plz
  attr_reader :kosten_traeger, :journale, :fw_einsaetze, :fw_entschaedigung, :fallstelle_teilnehmer
  attr_reader :konto_angaben, :stundenerfassung

  def initialize(path)
    @acdb = Mdb.open(path)
    @laender = Laender.new(@acdb)
    @sprachen = Sprachen.new(@acdb)
    @sprach_kenntnisse = SprachKenntnisse.new(@acdb)
    @personen_rollen = PersonenRolle.new(@acdb)
    @plz = Plz.new(@acdb)
    @familien_rollen = FamilienRollen.new(@acdb)
    @sprache_hauptperson = SpracheProHauptperson.new(@acdb, @sprachen, @sprach_kenntnisse)
    @begleitete = Begleitete.new(self)
    @haupt_personen = HauptPerson.new(self)
    @kosten_traeger = KostenTraeger.new(@acdb)
    @journale = Journale.new(@acdb)
    @fw_einsaetze = FreiwilligenEinsaetze.new(@acdb)
    @fw_entschaedigung = FreiwilligenEntschaedigung.new(@acdb)
    @fallstelle_teilnehmer = FalstelleTeilnehmer.new(@acdb)
    @konto_angaben = Kontoangaben.new(@acdb)
    @stundenerfassung = Stundenerfassung.new(@acdb)
  end

  def make_clients
    client_transformer = ClientTransform.new(self)
    client_count_before = Client.count
    @personen_rollen.all_clients.each do |key, ac_client|
      next if Import.where(
        importable_type: 'Client', access_id: ac_client[:pk_PersonenRolle].to_i
      ).any?
      client_attrs = client_transformer.prepare_attributes(ac_client)
      client = Client.new(client_attrs)
      client.user = User.first
      puts "Importing personen_rolle #{key} and Client.id: #{client.id}" if client.save!
    end
    puts "Imported #{Client.count - client_count_before} new clients from MS Access Database."
  end

  def make_volunteers
    volunteer_transformer = VolunteerTransform.new(self)
    volunteer_count_before = Volunteer.count
    @personen_rollen.all_volunteers.each do |key, ac_volunteer|
      next if Volunteer.where('access_import @> ?', {
        id_personen_rolle: ac_volunteer[:pk_PersonenRolle].to_i
      }.to_json).any?
      volunteer_attrs = volunteer_transformer.prepare_attributes(ac_volunteer)
      volunteer = Volunteer.new(volunteer_attrs)
      binding.pry
      # # volunteer.user = User.first
      # puts "Importing personen_rolle #{key} and Client.id: #{volunteer.id}" if volunteer.save!
    end
    # puts "Imported #{Client.count - volunteer_count_before} new clients from MS Access Datbase."
  end
end
