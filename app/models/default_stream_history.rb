# frozen_string_literal: true

# History of an organizations' default streams
class DefaultStreamHistory < ApplicationRecord
  belongs_to :stream
  has_one :organization, through: :stream, inverse_of: :default_stream_histories
  scope :recent, -> { order(start_time: :desc) }
end
