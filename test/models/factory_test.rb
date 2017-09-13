require 'test_helper'

class FactoryTest < ActiveSupport::TestCase
  test 'all factories can be created without errors' do
    FactoryGirl.lint traits:true
  end
end
