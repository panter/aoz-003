require 'test_helper'

class LanguageSkillTest < ActiveSupport::TestCase
  test 'language skill is not valid without a level' do
    german = LanguageSkill.create(language: 'FR')
    assert_equal 0, LanguageSkill.count
    refute german.valid?
  end
end
