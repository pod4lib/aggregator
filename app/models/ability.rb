# frozen_string_literal: true

# :nodoc:
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :manage, :all if user.has_role?(:admin)
    can :read, Organization if user
    can :manage, Organization, id: Organization.with_role(:owner, user).pluck(:id)
  end
end
