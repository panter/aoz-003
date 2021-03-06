module AccessImportSetup
  IMPORT_USER_EMAIL = 'aoz_access_importer@example.com'.freeze
  IMPORT_USER_NAME = 'AOZ Import'.freeze

  attr_reader :acdb
  attr_reader :import_user

  def initialize(path)
    ObjectSpace.define_finalizer(self, self.class.finalize)
    @import_user = create_or_fetch_import_user
    @acdb = Mdb.open(path)
    setup_class_variables(*instantiate_all_accessors)
    @sprache_pro_hauptperson.add_other_accessors(@sprachen, @sprach_kenntnisse)
    @einsatz_orte.add_other_accessors(@plz)
    @haupt_person.add_other_accessors(@plz, @laender, @sprache_pro_hauptperson, @sprachen,
      @sprach_kenntnisse)
    @kontoangaben.add_other_accessors(@plz)

    # don't overwrite imported accepted_at values
    Volunteer.skip_callback(:save, :record_acceptance_change, if: :accepted_at?)
    Client.skip_callback(:save, :record_acceptance_change, if: :accepted_at?)
  end

  def instantiate_all_accessors
    Dir['lib/access_import/accessors/*.rb']
      .map { |file| File.basename(file, '.*') }
      .reject { |name| name == 'accessor' }
      .map do |name|
        name.camelize.constantize.new(@acdb)
      end
  end

  def setup_class_variables(*accessors)
    accessors.each do |accessor|
      class_eval { attr_reader accessor.class.name.underscore.to_sym }
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  # Create Import user, needed for creating records that depend on a creator user
  #
  def create_or_fetch_import_user
    if User.with_deleted.exists?(email: IMPORT_USER_EMAIL)
      return User.with_deleted.find_by(email: IMPORT_USER_EMAIL).restore
    end
    user = User.create!(email: IMPORT_USER_EMAIL, password: SecureRandom.hex(60), role: 'superadmin')
    user.build_profile
    user.profile.build_contact(first_name: IMPORT_USER_NAME, last_name: IMPORT_USER_NAME,
      primary_email: IMPORT_USER_EMAIL, primary_phone: '0000', city: 'Zuerich', postal_code: '8000',
      street: 'xxxxxx')
    user.save!
    user
  end

  # Shell Output methods
  #

  def shell_message(message)
    puts message
  end

  def start_message(import_model)
    shell_message "Start Importing #{import_model.to_s.classify.pluralize}"
  end

  # display amount of imports for models
  def display_stats(*models)
    models.each do |model|
      shell_message stat_text(model)
    end
  end

  def stat_text(model)
    "Imported #{Import.where(importable_type: model.name)&.count} #{model.name.pluralize}."
  end

  def overall_stats
    shell_message "Overall imported #{Import.count} records"
    shell_message imported_stat_texts.join("\n")
  end

  def imported_stat_texts
    [Assignment, Client, Department, GroupAssignment, GroupOfferCategory, GroupOffer, Hour, Journal,
     Volunteer].map do |model|
      stat_text(model)
    end
  end
end
