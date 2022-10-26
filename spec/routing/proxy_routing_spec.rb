# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for ProxyController' do
  describe 'routing' do
    it 'proxies files to #show' do
      expect(get: '/file/1/test.txt').to route_to(
        controller: 'proxy', action: 'show', id: '1', filename: 'test.txt'
      )
    end
  end
end
