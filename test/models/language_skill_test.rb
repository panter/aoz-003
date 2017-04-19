require 'test_helper'

class LanguageSkillTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:client)
  end
end
