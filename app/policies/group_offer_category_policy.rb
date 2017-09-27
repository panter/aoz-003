class GroupOfferCategoryPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      if superadmin?
        all
      else
        none
      end
    end
  end

  alias_method :index?,                 :superadmin?
  alias_method :show?,                  :superadmin?
  alias_method :new?,                   :superadmin?
  alias_method :edit?,                  :superadmin?
  alias_method :create?,                :superadmin?
  alias_method :update?,                :superadmin?
end
