require_all 'lib/access_import'

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
    @personen_rollen.all_clients.each do |_key, ac_client|
      next if Client.where(
        'access_import @> ?',
        { id_personen_rolle: ac_client[:pk_PersonenRolle].to_i }.to_json
      ).any?
      client_params = client_transformer.prepare_attributes(ac_client).merge(user_id: User.first.id)
      Client.create(client_params)
    end
    puts "Imported #{Client.count - client_count_before} new clients from MS Access Datbase."
  end
end
