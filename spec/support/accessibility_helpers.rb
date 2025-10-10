# frozen_string_literal: true

module AccessibilityHelpers
  # An alias so our tests are less coupled to the aXe implementation
  def be_accessible(...)
    standards = %i[best-practice wcag2a wcag2aa wcag21a wcag21aa]

    be_axe_clean(...).according_to(standards).skipping('color-contrast')
  end
end

RSpec.configure do |config|
  config.include AccessibilityHelpers, type: :feature
end
