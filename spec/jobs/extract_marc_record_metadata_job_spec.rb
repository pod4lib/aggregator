# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractMarcRecordMetadataJob do
  include ActiveJob::TestHelper

  let(:upload) { create(:upload, :binary_marc) }

  it 'extract MarcRecord instances from data from each file' do
    expect do
      described_class.perform_now(upload)
    end.to change(MarcRecord, :count).by(1)

    expect(MarcRecord.last).to have_attributes marc001: 'a1297245', bytecount: 0, length: 1407, index: 0
  end

  it 'enqueues the stats job', skip: 'until we resolve: https://github.com/pod4lib/aggregator/issues/975' do
    expect do
      described_class.perform_now(upload)
    end.to enqueue_job(UpdateOrganizationStatisticsJob)
  end

  it 'marks the upload as processed' do
    expect do
      described_class.perform_now(upload)
    end.to change(upload, :processed?).from(false).to(true)
  end

  it 'records the number of records extracted' do
    expect do
      described_class.perform_now(upload)
    end.to change(upload, :marc_records_count).from(0).to(1)
  end
end
