module GroupAssignmentsAttributes
  extend ActiveSupport::Concern

  included do
    def group_assignments_attributes
      {
        group_assignments_attributes:
        [
          :id, :volunteer_id, :group_offer_id, :responsible, :period_start, :period_end, :_destroy
        ]
      }
    end
  end
end
