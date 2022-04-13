# frozen_string_literal: true

# :nodoc:
class DataController < ApplicationController
  authorize_resource({ :class => false })

  def index; end
end
