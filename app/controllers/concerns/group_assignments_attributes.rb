module GroupAssignmentsAttributes
  extend ActiveSupport::Concern

  included do
    def group_assignments_attributes
      {
        group_assignments_attributes:
        [
          :id, :volunteer_id, :group_offer_id, :responsible, :start_date, :end_date, :_destroy
        ]
      }
    end
  end
end
