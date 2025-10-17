# frozen_string_literal: true

module Dashboard
  # Users tab showing users by organization
  class UsersTabComponent < ViewComponent::Base
    def users_by_organization
      @users_by_organization ||= Organization.all.index_with(&:users)
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
