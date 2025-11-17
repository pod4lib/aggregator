# frozen_string_literal: true

module Downloaders
  # Component for rendering an icon indicating access status
  class AccessStatusIconComponent < ViewComponent::Base
    def initialize(can_access:)
      super()
      @can_access = can_access
    end

    def call
      tag.i(class: icon_class, aria: { hidden: true }) +
        tag.span(icon_text, class: 'visually-hidden')
    end

    def icon_class
      if can_access?
        'bi bi-check-circle-fill text-success'
      else
        'bi bi-dash'
      end
    end

    def icon_text
      if can_access?
        I18n.t('downloaders.access_status_icon_component.can_harvest')
      else
        I18n.t('downloaders.access_status_icon_component.cannot_harvest')
      end
    end

    def can_access?
      @can_access
    end
  end
end
