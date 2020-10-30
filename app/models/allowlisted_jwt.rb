# frozen_string_literal: true

# AR model to store the JTI of active JWTs for resource access
class AllowlistedJwt < ApplicationRecord
  belongs_to :resource, polymorphic: true
end
