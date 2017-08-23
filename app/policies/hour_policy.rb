class HourPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      all if superadmin?
    end
  end

  alias_method :index?,          :superadmin?
  alias_method :show?,           :superadmin_or_volunteer_related?
  alias_method :new?,            :volunteer_related?
  alias_method :edit?,           :volunteer_related?
  alias_method :create?,         :volunteer_related?
  alias_method :update?,         :volunteer_related?
  alias_method :destroy?,        :volunteer_related?
end
