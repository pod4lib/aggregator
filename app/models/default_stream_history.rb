# frozen_string_literal: true

# History of an organizations' default streams
class DefaultStreamHistory < ApplicationRecord
  belongs_to :organization
  belongs_to :stream
end
