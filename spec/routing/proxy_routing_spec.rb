# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProxyController, type: :routing do
  describe 'routing' do
    it 'proxies files to #show' do
      expect(get: '/file/1/test.txt').to route_to(
        controller: 'proxy', action: 'show', id: '1',
        filename: 'test', format: 'txt'
      )
    end
  end
end
