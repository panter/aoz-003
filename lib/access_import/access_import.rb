class AccessImport
  attr_reader :acdb

  def initialize(path)
    @acdb = Mdb.open(path)
    make_class_variables(*instantiate_all_accessors)
    @sprache_pro_hauptperson.add_other_accessors(@sprachen, @sprach_kenntnisse)
    @einsatz_orte.add_other_accessors(@plz)
    @haupt_person.add_other_accessors(@plz, @laender, @sprache_pro_hauptperson)
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

  def instantiate_all_accessors
    Dir['lib/access_import/accessors/*.rb']
      .reject { |file| file.slice(-11..-1) == 'accessor.rb' }
      .map do |file|
        file.split('/').last.slice(0..-4).camelize.constantize.new(@acdb)
      end
  end

  def make_class_variables(*accessors)
    accessors.each do |accessor|
      class_eval { attr_reader accessor.class.name.underscore.to_sym }
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end
end
