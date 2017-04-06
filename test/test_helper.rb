require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

configs = YAML.load_file('../../config/database.yml')
ActiveRecord::Base.configurations = configs

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
