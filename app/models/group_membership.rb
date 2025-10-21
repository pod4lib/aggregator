# frozen_string_literal: true

# Connects organizations to groups (many-to-many)
class GroupMembership < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :group
end
