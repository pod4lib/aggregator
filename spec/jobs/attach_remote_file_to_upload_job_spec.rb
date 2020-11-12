# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachRemoteFileToUploadJob, type: :job do
  before do
    allow(URI).to receive(:open).and_return(
      fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream')
    )
  end

  let(:upload) { FactoryBot.create(:upload, files: [], url: 'http://example.com/1297245.marc') }

  it 'attaches files at the given URL' do
    expect do
      described_class.perform_now(upload)
    end.to change(upload.files, :attached?).to(true)

    expect(upload.files.first.blob.checksum).to eq 'iXNNqQC8bbzJqws9rdm09Q=='
  end
end
