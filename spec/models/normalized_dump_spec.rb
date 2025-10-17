# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NormalizedDump do
  let(:organization) { create(:organization) }
  let(:upload) { create(:upload, :binary_marc, stream: organization.default_stream) }

  before do
    upload.files.blobs.first.analyze
    GenerateFullDumpJob.perform_now(organization.default_stream)
    # Manually set the count metadata
    organization.default_stream.reload.current_full_dump.marc21.attachment.metadata = { 'count' => 1 }
  end

  describe '#record_count' do
    it 'returns the number of records in the dump' do
      expect(organization.default_stream.reload.current_full_dump.record_count).to eq(1)
    end
  end
end
