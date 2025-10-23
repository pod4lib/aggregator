# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  let(:org1) { create(:organization) }
  let(:user) { create(:user) }
  let(:stream) { create(:stream) }

  describe '#current_page_class' do
    it 'returns "current" if the route matches the current page' do
      allow(helper).to receive(:current_page?).and_return true
      expect(helper.current_page_class('/website')).to equal 'current'
    end

    it 'returns nil if the route does not match the current page' do
      allow(helper).to receive(:current_page?).and_return false
      expect(helper.current_page_class('/website')).to be_nil
    end
  end

  describe '#datetime_display_format' do
    it 'returns datetime display format string configuration option for local_time library' do
      datetime_display_format_str = helper.datetime_display_format
      expect(datetime_display_format_str).to be('%B %e, %Y %l:%M%P %Z')
    end
  end
end
