# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractMarcRecordMetadataJob, type: :job do
  include ActiveJob::TestHelper

  let(:upload) { create(:upload, :binary_marc) }

  it 'extract MarcRecord instances from data from each file' do
    expect do
      described_class.perform_now(upload)
    end.to change(MarcRecord, :count).by(1)

    expect(MarcRecord.last).to have_attributes marc001: 'a1297245', bytecount: 0, length: 1407, index: 0
  end

  it 'enqueues the stats job' do
    expect do
      described_class.perform_now(upload)
    end.to enqueue_job(UpdateOrganizationStatisticsJob)
  end

  it 'tracks job statistics' do
    expect do
      described_class.perform_later(upload)
    end.to change(JobTracker, :count) # .by(1) # ... would be nice, but the test adapter
    # seems to change job ids between enqueue + perform...

    expect(JobTracker.last).to have_attributes(resource: upload, reports_on: upload.stream)
  end

  it 'cleans up job tracking after running' do
    described_class.perform_later(upload)
    perform_enqueued_jobs
    perform_enqueued_jobs
    expect(JobTracker.count).to eq 0
  end
end
