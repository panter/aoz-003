require 'test_helper'

class FactoryTest < ActiveSupport::TestCase
  test 'all factories can be created without errors' do
    FactoryBot.lint traits: true
  end
end
