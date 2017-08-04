
class AccessImport
  attr_reader :acdb, :begleitete, :haupt_personen, :personen_rollen, :familien_rollen
  attr_reader :laender, :sprachen, :sprach_kenntnisse, :sprache_hauptperson, :plz

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
      puts "Importing personen_rolle #{key} to Client.id: #{client.id}" if client.save!
    end
    puts "Imported #{Client.count - client_count_before} new clients from MS Access Database."
  end
end
