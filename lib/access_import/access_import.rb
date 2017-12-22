require 'securerandom'
require 'ostruct'

class AccessImport
  include TransformInstantiators

  attr_reader :acdb
  attr_reader :import_user

  IMPORT_USER_EMAIL = 'aoz_access_importer@example.com'.freeze
  IMPORT_USER_NAME = 'AOZ Import'.freeze

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
    puts 'Importing Departments'
    department_transform.import_all
    display_stats(Department)
  end

  def make_clients
    puts 'Importing Clients'
    client_transform.import_all
    display_stats(Client)
  end

  def make_volunteers
    puts 'Importing Volunteers'
    volunteer_transform.import_all
    display_stats(Volunteer)
  end

  def make_assignments
    puts 'Importing Assignments'
    assignment_transform.import_all
    display_stats(Assignment)
  end

  def make_group_offers
    puts 'Importing GroupOffers'
    kurs_transform.import_all
    group_offer_transform.import_all
    group_offer_transform.import_all(@freiwilligen_einsaetze.where_kurzeinsatz)
    display_stats(GroupOffer)
    display_stats(GroupAssignment)
  end

  def make_journal
    puts 'Importing Journals'
    journal_transform.import_all
    display_stats(Journal)
  end

  def instantiate_all_accessors
    Dir['lib/access_import/accessors/*.rb']
      .map { |file| File.basename(file, '.*') }
      .reject { |name| name == 'accessor' }
      .map do |name|
        name.camelize.constantize.new(@acdb)
      end
  end

  def display_stats(model)
    puts stat_text(model)
  end

  def stat_text(model)
    "Imported #{Import.where(importable_type: model.name)&.count} #{model.name.pluralize}."
  end

  def overall_stats
    puts "Overall imported #{Import.count} records"
    puts imported_stat_texts.join("\n")
  end

  def imported_stat_texts
    [Assignment, Client, Department, GroupAssignment, GroupOfferCategory, GroupOffer, Hour, Journal,
     Volunteer].map do |model|
      stat_text(model)
    end
  end

  def make_class_variables(*accessors)
    accessors.each do |accessor|
      class_eval { attr_reader accessor.class.name.underscore.to_sym }
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def create_or_fetch_import_user
    return User.find_by(email: IMPORT_USER_EMAIL) if User.exists?(email: IMPORT_USER_EMAIL)
    return User.deleted.find_by(email: IMPORT_USER_EMAIL).restore if User.deleted.exists?(email: IMPORT_USER_EMAIL)
    import_user = FactoryBot.create :user, email: IMPORT_USER_EMAIL, password: SecureRandom.hex(60)
    import_user.profile.contact.first_name = IMPORT_USER_NAME
    import_user.profile.contact.last_name = IMPORT_USER_NAME
    import_user.profile.contact.primary_email = IMPORT_USER_EMAIL
    import_user.save!
    import_user
  end

  def self.finalize
    proc { User.find_by(email: EMAIL).delete }
  end
end
