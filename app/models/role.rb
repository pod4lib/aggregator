# frozen_string_literal: true

# :nodoc:
class Role < ApplicationRecord
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :users, join_table: :users_roles
  # rubocop:enable Rails/HasAndBelongsToMany

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  # Current roles:
  # - member (resource = organization): can read shared data, see dashboards, but only create new
  #                                     uploads in their own organization
  # - owner (resource = organization): can manage the organization, its streams, and its members, etc
  # - admin: application-wide administrator
  # - superadmin: like admin, but gets the admin privileges without needing to opt-in. used for testing + local development
end
