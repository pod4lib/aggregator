# frozen_string_literal: true

module StatusIcons
  # Base class for status icon components
  class StatusIconComponent < ViewComponent::Base
    attr_reader :status, :classes, :show_label

    def initialize(status:, classes: '', show_label: false)
      @status = status
      @classes = classes
      @show_label = show_label
      super()
    end

    def call
      tag.span(class: classes) do
        tag.i(class: i_classes, role:, aria:) + label_tag
      end
    end

    def i_classes
      "#{icon_class} #{status} #{additional_classes}"
    end

    def additional_classes
      ''
    end

    def label_tag
      return unless show_label

      tag.span(class: 'ms-1 align-text-baseline') do
        label
      end
    end

    def role
      return if show_label

      'img'
    end

    def aria
      return { hidden: true } if show_label

      { label: }
    end

    def settings_data
      raise NotImplementedError, 'Subclasses must implement the settings_data method'
    end

    def icon_class
      settings_data[status]&.icon_class
    end

    def label
      settings_data[status]&.label
    end
  end
end
