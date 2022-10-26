# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for OrganizationsController' do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/organizations').to route_to('organizations#index')
    end

    it 'routes to #index as an xml sitemap' do
      expect(get: '/organizations/resourcelist').to route_to('organizations#index', format: :xml)
    end

    it 'routes to #index as an format-specific xml sitemap' do
      expect(get: '/organizations/normalized_resourcelist/marcxml').to route_to(
        'organizations#index', normalized: true, flavor: 'marcxml', format: :xml
      )
    end

    it 'routes to #new' do
      expect(get: '/organizations/new').to route_to('organizations#new')
    end

    it 'routes to #show' do
      expect(get: '/organizations/1').to route_to('organizations#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/organizations').to route_to('organizations#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/organizations/1').to route_to('organizations#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/organizations/1').to route_to('organizations#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/organizations/1').to route_to('organizations#destroy', id: '1')
    end

    # /edit route was disabled in favor of /provider_details and /organization_details
    it 'does not route to #edit' do
      expect(get: '/organizations/1/edit').not_to be_routable
    end

    it 'routes to #provider_details' do
      expect(get: '/organizations/1/provider_details').to route_to('organizations#provider_details', id: '1')
    end

    it 'routes to #organization_details' do
      expect(get: '/organizations/1/organization_details').to route_to('organizations#organization_details', id: '1')
    end
  end
end
