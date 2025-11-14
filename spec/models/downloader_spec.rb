# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Downloader do
  let(:group) { create(:group) }
  let(:organization) { create(:organization) }

  it 'can be successfully created when associated with a resource' do
    expect(described_class.create(organization: organization, resource: group)).to be_persisted
  end

  it 'cannot be successfully created if not associated with a resource' do
    expect(described_class.create(organization: organization)).not_to be_persisted
  end
end
