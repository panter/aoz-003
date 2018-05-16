require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  test 'seeds can be created without errors' do
    load Rails.root.join('db', 'seeds.rb')
  end
end
