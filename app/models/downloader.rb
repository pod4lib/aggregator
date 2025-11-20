# frozen_string_literal: true

# Class representing a downloader relationship between an organization and
# resources (a group or another organization) that are allowed to download from it
class Downloader < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :resource, polymorphic: true
end
