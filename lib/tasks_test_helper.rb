require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'
require 'roo'


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

  def extract_xlsx(filename)
    Roo::Spreadsheet.open("lib/access_import_test/#{filename}.xlsx", extension: 'xlsx')
  end

  def assert_xls_cols_equal(wb, row, offset, *columns)
    columns.each_with_index do |column, index|
      assert_equal column, wb.cell(row, index + 1 + offset)
    end
  end

  def really_destroy_with_deleted(*models)
    models.each do |model|
      model.with_deleted.map(&:really_destroy!)
    end
  end
end
