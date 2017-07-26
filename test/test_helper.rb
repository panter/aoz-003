require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'
require 'policy_assertions'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Warden::Test::Helpers

  DatabaseCleaner.strategy = :transaction

  def before_setup
    # FIXME: make sure all users are deleted, sometimes records stick around
    # when tests are aborted
    [:user, :volunteer, :client, :contact, :profile, :journal].each do |model|
      model.to_s.classify.constantize.with_deleted.map(&:really_destroy!)
    end

    super
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    super
  end

  def with_versioning
    was_enabled = PaperTrail.enabled?
    was_enabled_for_controller = PaperTrail.enabled_for_controller?
    PaperTrail.enabled = true
    PaperTrail.enabled_for_controller = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
      PaperTrail.enabled_for_controller = was_enabled_for_controller
    end
  end
end
