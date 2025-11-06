# frozen_string_literal: true

module Activity
  # Users tab showing users by organization
  class UsersTabComponent < ViewComponent::Base
    delegate :can?, :current_ability, to: :helpers

    def users_by_organization
      return [] unless can?(:read, User)

      @users_by_organization ||= Organization.accessible_by(current_ability).index_with(&:users)
    end

    def count_roles(users)
      highest_role_per_user = users.map(&:highest_role)

      {
        admin: highest_role_per_user.count(:admin),
        owner: highest_role_per_user.count(:owner),
        member: highest_role_per_user.count(:member)
      }
    end
  end
end
