# frozen_string_literal: true

# Back link component
class BackLinkComponent < ViewComponent::Base
  def call
    tag.div(class: 'my-2') do
      link_to(:back) do
        safe_join([tag.i(class: 'bi bi-arrow-left me-1'), 'Back'])
      end
    end
  end
end
