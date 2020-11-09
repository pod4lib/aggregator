# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :routing do
  describe 'routing' do
    it 'routes to #uploads' do
      expect(get: '/dashboard/uploads').to route_to(
        controller: 'dashboard', action: 'uploads'
      )
    end
  end
end
