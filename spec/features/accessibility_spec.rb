# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Site Accessibility', :js do
  describe 'the home page' do
    before { visit root_path }

    it 'is accessible, including the header and footer' do
      expect(page).to be_accessible
    end
  end
end
