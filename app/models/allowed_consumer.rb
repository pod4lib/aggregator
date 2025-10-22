# frozen_string_literal: true

# Class representing an allowed consumer relationship between an organization and another entity.
class AllowedConsumer < ApplicationRecord
  belongs_to :organization
  belongs_to :allowed_consumer, polymorphic: true
end
