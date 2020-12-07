# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateDeltaDumpJob, type: :job do
  let(:organization) { FactoryBot.create(:organization) }

  before do
    Timecop.travel(5.days.ago)
    organization.default_stream.uploads << FactoryBot.build(:upload, :binary_marc)
    organization.default_stream.uploads << FactoryBot.build(:upload, :binary_marc)
    GenerateFullDumpJob.perform_now(organization)

    Timecop.return
    organization.default_stream.uploads << FactoryBot.build(:upload, :binary_marc)
  end

  it 'creates a new normalized delta dump' do
    expect do
      described_class.perform_now(organization)
    end.to change { organization.default_stream.normalized_dumps.last.reload.delta_dump_xml.count }.by(1)
  end

  it 'contains just the new the MARC records from the organization' do
    described_class.perform_now(organization)

    download_and_uncompress(organization.default_stream.normalized_dumps.last.delta_dump_xml.last) do |file|
      expect(Nokogiri::XML(file).xpath('//marc:record', marc: 'http://www.loc.gov/MARC21/slim').count).to eq 1
      expect(file.rewind && file.read).to include '</collection>'
    end
  end

  describe '.enqueue_all' do
    it 'enqueues jobs for each organization' do
      expect do
        described_class.enqueue_all
      end.to enqueue_job(described_class).exactly(Organization.count).times
    end
  end

  def download_and_uncompress(attachment)
    attachment.download do |content|
      yield Zlib::GzipReader.new(StringIO.new(content))
    end
  end
end
