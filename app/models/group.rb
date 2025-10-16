# frozen_string_literal: true

# Group of organizations
class Group < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: %i[finders slugged]

  has_paper_trail

  has_many :group_memberships, dependent: :destroy
  has_many :organizations, through: :group_memberships
  has_one_attached :icon

  default_scope { order(name: :asc) }

  def display_name
    short_name.presence || name
  end

  def add_organization(organization)
    organization = Organization.friendly.find(organization) unless organization.is_a?(Organization)
    organizations << organization unless organizations.include?(organization)
  end

  def remove_organization(organization)
    organization = Organization.friendly.find(organization) unless organization.is_a?(Organization)
    organizations.delete(organization)
  end
end
