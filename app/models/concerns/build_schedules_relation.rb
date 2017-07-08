module BuildSchedulesRelation
  extend ActiveSupport::Concern

  included do
    after_initialize :build_schedules_relation

    # Ensures that the required Schedules are present in the model.
    #
    # It makes the need to do this in controller new actions obsolete.
    # The model takes care of its requirements itsself, as it should.
    def build_schedules_relation
      schedules << Schedule.build unless schedules.any?
    end
  end
end
