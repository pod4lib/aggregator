# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcProfilingJob do
  let(:upload) { FactoryBot.create(:upload, :binary_marc) }

  it 'stores some statistics about the MARC files' do
    upload.files.first.blob.update(metadata: { count: 1 })
    expect { described_class.perform_now(upload.files.first.blob) }.to change(MarcProfile, :count).by(1)
  end

  it 'counts field occurences' do
    upload.files.first.blob.update(metadata: { count: 1 })
    described_class.perform_now(upload.files.first.blob)

    expect(MarcProfile.last.field_frequency).to include('001' => 1, '245$a' => 1)
  end

  it 'counts field occurences by record' do
    upload.files.first.blob.update(metadata: { count: 1 })
    described_class.perform_now(upload.files.first.blob)

    expect(MarcProfile.last.record_frequency).to include('001' => 1, '245$a' => 1)
  end

  it 'stores a histogram of number of field occurences per record' do
    upload.files.first.blob.update(metadata: { count: 1 })
    described_class.perform_now(upload.files.first.blob)

    expect(MarcProfile.last.histogram_frequency).to include('001' => { '1' => 1 }, '245$a' => { '1' => 1 })
  end

  it 'samples some values' do
    upload.files.first.blob.update(metadata: { count: 1 })
    described_class.perform_now(upload.files.first.blob)

    expect(MarcProfile.last.sampled_values).to include('001' => ['a1297245'])
  end
end
