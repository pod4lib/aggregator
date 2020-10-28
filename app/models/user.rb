# frozen_string_literal: true

# :nodoc:
class User < ApplicationRecord
  rolify
  include Devise::JWT::RevocationStrategies::Allowlist
  belongs_to :organization

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
end
