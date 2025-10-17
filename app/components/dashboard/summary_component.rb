# frozen_string_literal: true

module Dashboard
  # Summary dashboard component showing recent uploads
  class SummaryComponent < ViewComponent::Base
    def initialize(uploads:)
      @uploads = uploads
      super()
    end
  end
end
