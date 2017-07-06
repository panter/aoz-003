class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  acts_as_paranoid
  has_paper_trail

  def self.find_version_author(version)
    version.terminator
  end
end
