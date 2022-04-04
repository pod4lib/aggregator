# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#bootstrap_icon' do
    it 'renders an icon given a valid Bootstrap icon class' do
      icon = helper.bootstrap_icon('search')
      expect(icon).to have_css('svg.bi.bi-search')
    end

    it 'applies provided classes to icon wrapper' do
      icon = helper.bootstrap_icon('search', class: 'example-class')
      expect(icon).to have_css('span.example-class')
    end

    it 'handles invalid icon classes by returning nil' do
      icon = helper.bootstrap_icon('293847uijs', class: 'example-class')
      expect(icon).to be_nil
    end
  end
end
