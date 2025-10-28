# frozen_string_literal: true

# Icon label component
class IconLabelComponent < ViewComponent::Base
  def initialize(icon:)
    @icon = icon
    super()
  end

  attr_reader :icon
end
