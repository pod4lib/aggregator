# frozen_string_literal: true

module Dashboard
  # Access tab showing which organizations have access to which data
  class AccessTabComponent < ViewComponent::Base
    def initialize
      super
      @organizations = Organization.all
    end
  end
end
