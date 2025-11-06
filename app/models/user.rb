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

    return :admin if roles.include?('admin') || roles.include?('superadmin')
    return :owner if roles.include? 'owner'

    :member if roles.include? 'member'
  end

  def acting_as_superadmin?
    return @acting_as_superadmin unless @acting_as_superadmin.nil?

    @acting_as_superadmin = has_role?(:superadmin) || ActiveModel::Type::Boolean.new.cast(
      Thread.current[:acting_as_superadmin]
    )
  end
end
