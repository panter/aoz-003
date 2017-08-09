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
    transformer = ClientTransform.new(@begleitete, @haupt_person, @familien_rollen)
    make(@personen_rolle.all_clients, transformer, Client) do |client, personen_rolle|
      client = personen_rollen_create_update_conversion(client, personen_rolle)
      client.user = User.first
      if personen_rolle[:d_Rollenende]
        client.state = Client::FINISHED
        " -- Client was set to state finished at #{personen_rolle[:d_Rollenende]}  ----"
      end
    end
  end

  def make_volunteers
    transformer = VolunteerTransform.new(@haupt_person)
    make(@personen_rolle.all_volunteers, transformer, Volunteer) do |volunteer, personen_rolle|
      volunteer = personen_rollen_create_update_conversion(volunteer, personen_rolle)
      if personen_rolle[:d_Rollenende]
        volunteer.state = Volunteer::RESIGNED
        " -- Volunteer was set to state finished at #{personen_rolle[:d_Rollenende]}  ----"
      end
    end
  end

  def personen_rollen_create_update_conversion(model_record, personen_rolle)
    model_record.created_at = personen_rolle[:d_Rollenbeginn]
    model_record.updated_at = personen_rolle[:d_MutDatum]
    model_record
  end

  def make(base_entities, transformer, destination_model)
    records_before = destination_model.count
    base_entities.each do |key, entity|
      next if Import.where(importable_type: destination_model.to_s, access_id: key).any?
      import_record = destination_model.new(transformer.prepare_attributes(entity))
      handler_message = yield(import_record, entity)
      import_record.save!
      puts "Importing personen_rolle #{key} to #{destination_model}.id: #{import_record.id}#{handler_message}"
    end
    message = "Imported #{destination_model.count - records_before} new "
    puts "#{message}#{destination_model.class.name} from MS Access Database."
  end

  def instantiate_all_accessors
    Dir.entries('lib/access_import/accessors').slice(2..-1).map do |file|
      file.slice(0..-4).camelize.constantize.new(@acdb) unless file == 'accessor.rb'
    end.compact
  end

  def make_class_variables(*accessors)
    accessors.each do |accessor|
      class_eval { attr_reader accessor.class.name.underscore.to_sym }
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end
end
