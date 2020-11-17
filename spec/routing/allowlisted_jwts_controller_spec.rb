# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllowlistedJwtsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/organizations/1/allowlisted_jwts').to route_to('allowlisted_jwts#index', organization_id: '1')
    end

    it 'routes to #new' do
      expect(get: '/organizations/1/allowlisted_jwts/new').to route_to('allowlisted_jwts#new', organization_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/organizations/1/allowlisted_jwts').to route_to('allowlisted_jwts#create', organization_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/organizations/1/allowlisted_jwts/2').to route_to(
        'allowlisted_jwts#destroy', id: '2', organization_id: '1'
      )
    end
  end
end
