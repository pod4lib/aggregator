# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for DashboardController' do
  describe 'routing' do
    it 'routes to #summary' do
      expect(get: '/dashboard/summary').to route_to(
        controller: 'dashboard', action: 'summary'
      )
    end
  end
end
