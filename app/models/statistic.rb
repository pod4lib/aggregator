# frozen_string_literal: true

# Time-based statistics or an organization
class Statistic < ApplicationRecord
  scope :latest, -> { order(date: :desc).limit(1) }
  belongs_to :resource
end
