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
      User, Volunteer, Client, ClientNotification, Contact, Profile, Journal, Assignment,
      Department, LanguageSkill, Relative, GroupOffer, GroupAssignment, Feedback, TrialFeedback,
      BillingExpense, Certificate, GroupAssignmentLog, Hour, Import
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

  def get_xls_from_response(url)
    get url
    excel_file = Tempfile.new
    excel_file.write(response.body)
    excel_file.close
    Roo::Spreadsheet.open(excel_file.path, extension: 'xlsx')
  end

  def assert_xls_cols_equal(wb, row, offset, *columns)
    columns.each_with_index do |column, index|
      assert_equal column, wb.cell(row, index + 1 + offset)
    end
  end

  def destroy_really_all(model)
    model.with_deleted.map(&:really_destroy!)
  end

  def assert_xls_row_empty(wb, row, cols = 8)
    (1..cols).to_a.each { |column| assert_nil wb.cell(row, column) }
  end
end
