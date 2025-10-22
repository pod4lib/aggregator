# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateInterstreamDeltaDumpJob do
  let(:organization) { create(:organization) }
  let(:stream_a) { organization.streams.create(slug: 'a') }
  let(:stream_b) { organization.streams.create(slug: 'b') }

  before do
    Timecop.travel(5.days.ago)
    stream_a.uploads << build(:upload, :deletes)
    stream_a.uploads << build(:upload, :binary_marc)
    stream_a.uploads << build(:upload, :marc_xml)
    stream_b.uploads << build(:upload, :marc_xml3)
    GenerateFullDumpJob.perform_now(stream_a)

    Timecop.travel(3.days.ago)
    stream_b.uploads << build(:upload, :modified_binary_marc)
    stream_b.uploads << build(:upload, :marc_xml2)
    stream_b.uploads << build(:upload, :marc_xml3)
    GenerateFullDumpJob.perform_now(stream_b)

    Timecop.return
  end

  it 'creates a new normalized interstream delta dump' do
    expect do
      described_class.perform_now(stream_a, stream_b)
    end.to change { stream_b.reload.interstream_delta_dumps.count }.by(1)
  end

  it 'creates delete entries for records in the previous stream that are not in the current stream' do
    described_class.perform_now(stream_a, stream_b)

    interstream_delta = stream_b.reload.interstream_delta_dumps.last

    interstream_delta.deletes.download do |file|
      expect(file.lines.map(&:strip)).to contain_exactly('a0240', 'a111', 'a12345', 'a333')
    end
  end

  it 'includes entries for changed records' do
    described_class.perform_now(stream_a, stream_b)

    interstream_delta = stream_b.reload.interstream_delta_dumps.last

    records = MarcRecordService.new(interstream_delta.marcxml)

    expect(records.pluck('001').map(&:value)).to contain_exactly('a1297245')
  end
end
