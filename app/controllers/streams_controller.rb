# frozen_string_literal: true

# Controller to handle streams
class StreamsController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization

  def show; end

  def removed_since_previous_stream
    render plain: @stream.removed_since_previous_stream.join("\n")
  end
end
