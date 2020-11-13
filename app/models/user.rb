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

  def to_s
    return email if name.blank?

    "#{name} (#{email})"
  end
end
