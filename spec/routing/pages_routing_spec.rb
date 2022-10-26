# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for PagesController' do
  describe 'routing' do
    it 'routes to #home' do
      expect(get: '/').to route_to('pages#home')
    end

    it 'routes to #api' do
      expect(get: '/api').to route_to('pages#api')
    end

    it 'routes to #data' do
      expect(get: '/data').to route_to('pages#data')
    end
  end
end
