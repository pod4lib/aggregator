# frozen_string_literal: true

# History of an organizations' default streams
# @deprecated
class DefaultStreamHistory < ApplicationRecord
  belongs_to :stream
end
