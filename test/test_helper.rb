require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'
require 'policy_assertions'
require 'utility/reminder_mailing_builder'
require 'utility/group_offer_and_assignment'

class ActionMailer::TestCase
  include ReminderMailingBuilder
  include GroupOfferAndAssignment
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
      User, Volunteer, Client, ClientNotification, Contact, Profile, Journal, AssignmentLog,
      Assignment, Department, LanguageSkill, Relative, GroupOffer, GroupAssignment, Feedback,
      TrialFeedback, BillingExpense, Certificate, GroupAssignmentLog, Hour, Import, Event,
      EventVolunteer
    )

    super

    FFaker::UniqueUtils.clear
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    super
  end

  def get_xls_from_response(url)
    get url
    assert response.success?
    assert_equal Mime[:xlsx], response.content_type
    excel_file = Tempfile.new
    excel_file.write(response.body)
    excel_file.close
    Roo::Spreadsheet.open(excel_file.path, extension: 'xlsx')
  end

  def assert_xls_cols_equal(wb, row, offset, *columns)
    columns.each_with_index do |column, index|
      assert_equal column.to_s, wb.cell(row, index + 1 + offset).to_s
    end
  end

  def really_destroy_with_deleted(*models)
    models.each do |model|
      model.with_deleted.map(&:really_destroy!)
    end
  end

  def assert_xls_row_empty(wb, row, cols = 8)
    (1..cols).to_a.each { |column| assert_nil wb.cell(row, column) }
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
end
