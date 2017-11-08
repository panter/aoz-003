require 'test_helper'

class LanguageSkillTest < ActiveSupport::TestCase
  test 'language skill is valid' do
    german = LanguageSkill.create!(language: 'DE', level: 'good')
    assert_equal 1, LanguageSkill.count
    assert german.valid?
  end

  test 'language skill is not valid without a level' do
    german = LanguageSkill.create(language: 'FR')
    assert_equal 0, LanguageSkill.count
    refute german.valid?
  end
end
