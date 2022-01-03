# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllowlistedJwt do
  let(:organization) { create(:organization) }

  it 'can be successfully created when assocated with a resource' do
    expect(described_class.create(resource: organization)).to be_persisted
  end

  it 'mints a new JTI' do
    token = described_class.create(resource: organization)

    expect(token.jti).to be_present
  end

  it 'mints unique JTIs' do
    expect do
      described_class.create(resource: organization)
      described_class.create(resource: organization)
      described_class.create(resource: organization)
    end.to change(described_class, :count).by(3)
  end

  it 'cannot be successfully created if not assocated with a resource' do
    expect(described_class.create(jti: 'abc123')).not_to be_persisted
  end

  describe '#last_used' do
    it 'is nil if the updated and created at times are the same' do
      expect(described_class.create(resource: organization).last_used).to be_nil
    end

    it 'is the updated at timestamp if it differs from the created at' do
      token = described_class.create(resource: organization)
      token.update(updated_at: Time.zone.now)
      token.reload
      expect(token.last_used).to eq token.updated_at
    end
  end
end
