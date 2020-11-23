# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcProfilingJob do
  include ActiveJob::TestHelper

  let(:upload) { FactoryBot.create(:upload, :small_batch_gz) }

  it 'stores some statistics about the MARC files' do
    upload.files.first.blob.update(metadata: { count: 1 })
    expect { described_class.perform_now(upload.files.first.blob) }.to change(MarcProfile, :count).by(1)
  end

  it 'counts field occurences' do
    upload.files.first.blob.update(metadata: { count: 1 })
    described_class.perform_now(upload.files.first.blob)

    expect(MarcProfile.last.field_frequency).to include('001' => 50, '245$a' => 50, '690$d' => 8)
  end

  it 'counts field occurences by record' do
    upload.files.first.blob.update(metadata: { count: 1 })
    described_class.perform_now(upload.files.first.blob)

    expect(MarcProfile.last.record_frequency).to include('001' => 50, '245$a' => 50, '690$d' => 4)
  end

  it 'stores a histogram of number of field occurences per record' do
    upload.files.first.blob.update(metadata: { count: 1 })
    described_class.perform_now(upload.files.first.blob)

    expect(MarcProfile.last.histogram_frequency).to include(
      '001' => { '1' => 50 }, '245$a' => { '1' => 50 }, '690$d' => { '2' => 4 }
    )
  end

  it 'samples some values' do
    upload.files.first.blob.update(metadata: { count: 1 })
    described_class.perform_now(upload.files.first.blob)

    expect(MarcProfile.last.sampled_values['001'].length).to eq 25
  end

  it 'tracks job statistics' do
    expect do
      described_class.perform_later(upload.files.first.blob)
    end.to change(JobTracker, :count) # .by(1) # ... would be nice, but the test adapter
    # seems to change job ids between enqueue + perform...

    expect(JobTracker.last).to have_attributes(resource: upload.files.first.blob, reports_on: upload.stream)
  end

  it 'cleans up job tracking after running' do
    described_class.perform_later(upload.files.first.blob)
    perform_enqueued_jobs
    expect(JobTracker.count).to eq 0
  end
end
