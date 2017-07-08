module BuildContactRelation
  extend ActiveSupport::Concern

  included do
    after_initialize :build_contact_relation

    # Ensures that the model has its required relation.
    #
    # It makes doing this in every controller new action obsolete.
    # The model takes care of its requirements itsself, as it should.
    def build_contact_relation
      self.contact = Contact.new unless contact
    end
  end
end
