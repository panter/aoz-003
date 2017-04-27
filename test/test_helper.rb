require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Warden::Test::Helpers

  DatabaseCleaner.strategy = :transaction

  def before_setup
    super
    I18n.default_locale = :en
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    super
  end
end
