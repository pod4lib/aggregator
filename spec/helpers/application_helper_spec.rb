# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  let(:org1) { create(:organization) }
  let(:user) { create(:user) }

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

  describe '#job_status_tabs_collapse' do
    it 'applies class to show tab when tab expanded is false and job count is positive' do
      set_tab_class = helper.job_status_tabs_collapse(false, 3)
      expect(set_tab_class).to be('show')
    end

    it 'applies class to collapse tab when tab expanded is true and job count is positive' do
      set_tab_class = helper.job_status_tabs_collapse(true, 3)
      expect(set_tab_class).to be('collapsed')
    end

    it 'applies class to collapse tab when tab expanded is true and job count is zero' do
      set_tab_class = helper.job_status_tabs_collapse(true, 0)
      expect(set_tab_class).to be('collapsed')
    end

    it 'applies class to collapse tab when tab expanded is false and job count is zero' do
      set_tab_class = helper.job_status_tabs_collapse(false, 0)
      expect(set_tab_class).to be('collapsed')
    end
  end

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
      datetime_display_format_str = helper.datetime_display_format()
      expect(datetime_display_format_str).to be('%B %e, %Y %l:%M%P %Z')
    end
  end
end
