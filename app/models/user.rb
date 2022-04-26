# frozen_string_literal: true

# :nodoc:
class User < ApplicationRecord
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :invitable, :confirmable

  has_many :uploads # rubocop:disable Rails/HasManyOrHasOneDependent

  def organizations(which_roles = %i[owner member])
    Organization.with_roles(which_roles, self).uniq
  end

  # FIXME: see https://github.com/pod4lib/aggregator/issues/503
  def organization
    organizations.first
  end

  def to_s
    return email if name.blank?

    "#{name} (#{email})"
  end
end
