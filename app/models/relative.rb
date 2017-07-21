class Relative < ApplicationRecord
  include YearCollection

  belongs_to :relativeable, polymorphic: true, optional: true

  def to_s
    relation_human = relation ? I18n.t(relation, scope: [:relation]) : ''
    [full_name, birth_year.try(:year), relation_human].reject(&:blank?).join(', ')
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.relation_collection
    [:wife, :husband, :mother, :father, :daughter, :son, :sister, :brother, :aunt, :uncle]
  end
end
