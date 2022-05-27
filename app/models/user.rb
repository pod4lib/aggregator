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
  has_many :organizations, through: :roles, source: :resource, source_type: :Organization

  def to_s
    return email if name.blank?

    "#{name} (#{email})"
  end

  def highest_role
    roles = self.roles.map(&:name).uniq

    return :admin if roles.include? 'admin'
    return :owner if roles.include? 'owner'
    return :member if roles.include? 'member'
  end
end
