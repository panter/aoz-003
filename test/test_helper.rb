require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'
require 'policy_assertions'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include Warden::Test::Helpers

  DatabaseCleaner.strategy = :transaction

  def before_setup
    # FIXME: make sure all users are deleted, sometimes records stick around
    # when tests are aborted
    [
      User, Volunteer, Client, Contact, Profile, Journal, Assignment,
      Department, LanguageSkill, Relative, GroupOffer, GroupAssignment, Feedback, BillingExpense,
      Certificate, GroupAssignmentLog, Hour, Import, Reminder
    ].each do |model|
      model.with_deleted.map(&:really_destroy!)
    end

    super
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    super
  end
end
