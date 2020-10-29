# frozen_string_literal: true

class AllowlistedJwt < ApplicationRecord
  belongs_to :resource, polymorphic: true
end
