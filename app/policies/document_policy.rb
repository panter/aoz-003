class DocumentPolicy < ApplicationPolicy
  alias_method :new?,     :superadmin?
  alias_method :create?,  :superadmin?
  alias_method :index?,   :allow_all!
  alias_method :show?,    :allow_all!
  alias_method :edit?,    :superadmin?
  alias_method :update?,  :superadmin?
  alias_method :destroy?, :superadmin?
end
