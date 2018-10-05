module MissionEitherOneRelation
  extend ActiveSupport::Concern

  included do
    # relates to either Assignment or GroupAssignment (not GroupOffer!)
    belongs_to :assignment, optional: true
    belongs_to :group_assignment, optional: true

    validate :validate_group_assignment_or_assignment_present

    def mission=(mission)
      if mission.class.name == 'Assignment'
        self.assignment = mission
      else
        self.group_assignment = mission
      end
    end

    def mission
      group_assignment || assignment
    end

    private

    def validate_group_assignment_or_assignment_present
      errors.add(:association_insuficient) if assignment.blank? && group_assignment.blank?
    end
  end
end
