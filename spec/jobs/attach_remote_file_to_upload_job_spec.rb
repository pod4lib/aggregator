# frozen_string_literal: true

require 'rails_helper'
require 'delegate'

class RemoteUploadFixture < SimpleDelegator
  attr_writer :meta

  def meta
    @meta ||= {}
  end
end

RSpec.describe AttachRemoteFileToUploadJob, type: :job do
  before do
    allow(URI).to receive(:parse).with(anything).and_return(instance_double('URI::HTTP', host: 'example.com', open: fixture))
  end

  let(:fixture) do
    RemoteUploadFixture.new(fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream'))
  end

  let(:upload) { FactoryBot.create(:upload, files: [], url: 'http://example.com/1297245.marc') }

  it 'attaches files at the given URL' do
    expect do
      described_class.perform_now(upload)
    end.to change(upload.files, :attached?).to(true)
    expect(upload.files.first.blob.checksum).to eq 'iXNNqQC8bbzJqws9rdm09Q=='
  end

  it 'gets the file name from the url' do
    described_class.perform_now(upload)
    expect(upload.files.first.filename).to eq '1297245.marc'
  end

  context 'when the url does not look like a file' do
    let(:upload) { FactoryBot.create(:upload, files: [], url: 'http://example.com/1297245/marc/data') }

    it 'uses the upload name as a placeholder' do
      described_class.perform_now(upload)
      expect(upload.files.first.filename.to_s).to eq upload.name.parameterize(preserve_case: true)
    end
  end

  context 'when the file has a ContentDisposition' do
    before do
      fixture.meta = { 'content-disposition' => 'attachement;filename="CD-filename.xml"' }
    end

    it 'gets the filename from the content disposition when present' do
      expect(upload.files).to be_blank
      described_class.perform_now(upload)
      expect(upload.files.first.filename).to eq 'CD-filename.xml'
    end
  end
end
