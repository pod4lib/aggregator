# frozen_string_literal: true

module AllowedConsumers
  # Component for rendering the record access form
  class RecordAccessFormComponent < ViewComponent::Base
    def initialize(organization:)
      super()
      @organization = organization
    end

    def render?
      helpers.can?(:manage, @organization)
    end
  end
end
