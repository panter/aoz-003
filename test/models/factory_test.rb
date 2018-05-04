require 'test_helper'

class FactoryTest < ActiveSupport::TestCase
  test 'all factories can be created without errors' do
    DatabaseCleaner.cleaning do
      FactoryBot.factories.to_a.in_groups_of(5, false) do |factories|
        FFaker::UniqueUtils.clear
        FactoryBot.lint factories, traits: true
      end
    end
  end
end
