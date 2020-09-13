# frozen_string_literal: true

# :nodoc:
class Upload < ApplicationRecord
  belongs_to :stream
  has_one :organization, through: :stream

  has_many_attached :files
end
