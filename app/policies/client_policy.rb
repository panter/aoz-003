class ClientPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.superadmin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  attr_reader :user, :client

  def initialize(user, client)
    @user = user
    @client = client
  end

  delegate :superadmin?, to: :user
  delegate :social_worker?, to: :user

  def super_or_users_client?
    superadmin? || social_worker? && client.user_id == user.id
  end

  def superadmin_or_social_worker?
    superadmin? || social_worker?
  end

  alias_method :destroy?,           :superadmin?
  alias_method :need_accompanying?, :superadmin?
  alias_method :supervisor?,        :superadmin?

  alias_method :show?,              :super_or_users_client?
  alias_method :edit?,              :super_or_users_client?
  alias_method :update?,            :super_or_users_client?

  alias_method :index?,             :superadmin_or_social_worker?
  alias_method :new?,               :superadmin_or_social_worker?
  alias_method :create?,            :superadmin_or_social_worker?
end
