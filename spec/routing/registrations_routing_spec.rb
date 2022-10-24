# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for RegistrationsController' do
  describe 'routing' do
    it 'uses local registrations_controller to send profile updates' do
      expect(put: '/users').to route_to('registrations#update')
    end

    it 'uses devise controller for profile destroy' do
      expect(delete: '/users').to route_to('devise/registrations#destroy')
    end

    it 'uses devise controller for profile edit page' do
      expect(get: '/users/edit').to route_to('devise/registrations#edit')
    end
  end
end
