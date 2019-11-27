module ProcessedByConcern
  extend ActiveSupport::Concern

  included do
    def register_acceptance_change(resource)
      return unless resource.will_save_change_to_attribute?(:acceptance)

      if resource.respond_to?("#{resource.acceptance}_by_id".to_sym)
        resource["#{resource.acceptance}_by_id".to_sym] = current_user.id
      end
    end
  end
end
