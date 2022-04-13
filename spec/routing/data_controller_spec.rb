# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/data').to route_to('data#index')
    end
  end
end
