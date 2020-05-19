class TrialPeriodPolicy < ApplicationPolicy
  alias_method :index?, :superadmin?
  alias_method :update?, :superadmin?
  alias_method :verify?, :superadmin?
end
