# frozen_string_literal: true

# History of an organizations' default streams
class DefaultStreamHistory < ApplicationRecord
  belongs_to :organization
  belongs_to :stream

  def previous_stream_history
    # Get previous stream history
    histories = organization.default_stream_histories.all.order(start_time: :desc)
    index = histories.find_index { |stream_history| stream_history.stream == stream }
    histories[index + 1]
  end
end
