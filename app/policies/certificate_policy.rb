class CertificatePolicy < ApplicationPolicy
  alias_method :new?,     :superadmin?
  alias_method :create?,  :superadmin?
  alias_method :index?,   :superadmin?
  alias_method :show?,    :superadmin?
  alias_method :destroy?, :superadmin?
end
