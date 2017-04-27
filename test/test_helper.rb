require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
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

  def permit(current_user, record, action)
    self.class.to_s.gsub(/Test/, '')
        .constantize.new(current_user, record)
        .public_send("#{action}?")
  end

  def forbid(current_user, record, action)
    !permit(current_user, record, action)
  end
end
