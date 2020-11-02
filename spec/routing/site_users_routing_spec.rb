# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteUsersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/site_users').to route_to(
        'site_users#index'
      )
    end

    it 'routes to #update' do
      expect(patch: '/site_users/1').to route_to(
        'site_users#update', id: '1'
      )
    end
  end
end
