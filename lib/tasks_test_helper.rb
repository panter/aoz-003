require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'


class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include Warden::Test::Helpers

  DatabaseCleaner.strategy = :transaction

  def before_setup
    super
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    super
  end

  def really_destroy_with_deleted(*models)
    models.each do |model|
      model.with_deleted.map(&:really_destroy!)
    end
  end
end
