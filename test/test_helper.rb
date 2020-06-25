require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'
require 'policy_assertions'
require 'webdrivers/chromedriver'

Webdrivers.install_dir = '.ci-cache/webdrivers'

Dir[Rails.root.join 'test/utility/**/*.rb'].each { |path| require path }

class ActionMailer::TestCase
  include ReminderMailingBuilder
  include GroupOfferAndAssignment
end

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include Warden::Test::Helpers
  include ReminderMailingBuilder
  include GroupOfferAndAssignment

  DatabaseCleaner.strategy = :transaction

  def before_setup
    # FIXME: make sure all users are deleted, sometimes records stick around
    # when tests are aborted
    really_destroy_with_deleted(
      Hour, Journal, BillingExpense, Certificate, Import,
      AssignmentLog, Assignment, GroupAssignmentLog, GroupAssignment, GroupOffer,
      ClientNotification, LanguageSkill, Relative, Event, EventVolunteer,
      Volunteer, Client, User, Contact, Department, SemesterProcess, SemesterFeedback,
      SemesterProcessVolunteer, SemesterProcessVolunteerMission
    )

    super

    FFaker::UniqueUtils.clear
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    Warden.test_reset!
    super
  end

  def really_destroy_with_deleted(*models)
    models.each do |model|
      model.with_deleted.map(&:really_destroy!)
    end
  end

  def controllers_action_list(controller_name = nil)
    controller_name ||= self.class.name.remove('PolicyTest').underscore.pluralize
    Rails
      .application.routes.routes
      .find_all { |route| route.defaults[:controller] == controller_name.to_s }
      .map { |route| route.defaults[:action] }.uniq
      .map { |action| [action.to_sym, "#{action}?"] }.to_h
  end

  def actions_list(*choices, except: nil)
    if choices.any?
      controllers_action_list.values_at(
        *choices.map { |choice| choice.to_s.remove(/\?$/).to_sym }
      )
    elsif except.present?
      controllers_action_list.except(*except).values
    else
      controllers_action_list.values
    end
  end

  def time_z(year, month = nil, day = nil, hour = 0, minute = 0)
    year, month, day = year.split('-').map(&:to_i) if month.blank?
    Time.zone.local(year, month, day, hour, minute)
  end
end
