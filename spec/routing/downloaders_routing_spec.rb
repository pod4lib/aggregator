# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for DownloadersController' do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/organizations/1/downloaders').to route_to(
        'downloaders#index', organization_id: '1'
      )
    end

    it 'routes to #create' do
      expect(post: '/organizations/1/downloaders').to route_to(
        'downloaders#create', organization_id: '1'
      )
    end

    it 'routes to #destroy' do
      expect(delete: '/organizations/1/downloaders/2').to route_to(
        'downloaders#destroy', organization_id: '1', id: '2'
      )
    end
  end
end
