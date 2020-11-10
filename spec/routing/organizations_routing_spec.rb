# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationsController, type: :routing do
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

    it 'routes to #edit' do
      expect(get: '/organizations/1/edit').to route_to('organizations#edit', id: '1')
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
  end
end
