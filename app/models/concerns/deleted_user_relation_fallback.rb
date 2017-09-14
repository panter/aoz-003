module DeletedUserRelationFallback
  extend ActiveSupport::Concern

  included do
    def user
      super || User.deleted.find_by(id: user_id)
    end
  end
end
