# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllowlistedJwt do
  it 'can be successfully created when assocated with a resource' do
    org = FactoryBot.create(:organization)

    expect(described_class.create(jti: 'abc123', resource: org)).to be_persisted
  end

  it 'cannot be successfully created if not assocated with a resource' do
    expect(described_class.create(jti: 'abc123')).not_to be_persisted
  end
end
