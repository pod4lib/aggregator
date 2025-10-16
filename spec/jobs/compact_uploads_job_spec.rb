# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompactUploadsJob do
  let(:organization) { create(:organization) }

  before do
    Timecop.travel(12.months.ago)
    15.times { organization.default_stream.uploads << create(:upload, :binary_marc) }

    Timecop.return

    GenerateFullDumpJob.perform_now(organization)
  end

  it 'compacts old uploads into a single upload' do # rubocop:disable RSpec/ExampleLength
    expect do
      described_class.perform_now(organization.default_stream, age: 6.months, min_uploads: 5)
    end.to change(organization.uploads.active, :count).from(15).to(5 + 1) # 5 recent + 1 compacted
                                                      .and change(organization.uploads.active.where(status: 'compacted'),
                                                                  :count).from(0).to(1)

    aggregate_failures 'checking compacted upload' do
      expect(organization.uploads.active.where(status: 'compacted').first.marc_records.count).to eq 1
      expect(organization.marc_records.count).to eq 6
    end
  end
end
