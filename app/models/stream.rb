# frozen_string_literal: true

# :nodoc:
class Stream < ApplicationRecord
  belongs_to :organization

  has_many_attached :snapshots
end
