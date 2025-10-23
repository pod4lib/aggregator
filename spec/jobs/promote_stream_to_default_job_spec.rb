# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromoteStreamToDefaultJob do
  let(:organization) { create(:organization) }
  let(:current_default_stream) { organization.default_stream }
  let(:new_pending_stream) { create(:stream, organization: organization, status: 'pending') }

  before do
    new_pending_stream.uploads << build(:upload, :binary_marc)
  end

  it 'runs the GenerateFullDumpJob if there is no full dump' do
    expect do
      described_class.perform_now(new_pending_stream)
    end.to change { new_pending_stream.full_dumps.count }.from(0).to(1)
  end

  it 'makes the pending stream the default stream' do
    described_class.perform_now(new_pending_stream)

    expect(current_default_stream.reload).to have_attributes default: false
    expect(new_pending_stream.reload).to have_attributes default: true
  end
end
