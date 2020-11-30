# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractFilesJob, type: :job do
  let!(:upload) { FactoryBot.create(:upload, :tar_gz) }

  it 'creates additional uploads for each extracted file' do
    expect do
      described_class.perform_now(upload)
    end.to change(upload.stream.uploads, :count).by(47)
  end

  it 'marks the extracted upload as archived' do
    expect do
      described_class.perform_now(upload)
    end.to change { upload.reload.status }.from('active').to('archived')
  end

  context 'with a non-tar file' do
    let!(:upload) { FactoryBot.create(:upload, :binary_marc) }

    it 'does nothing' do
      expect do
        described_class.perform_now(upload)
      end.to change(Upload, :count).by(0)
    end
  end

  context 'with a multi-file upload' do
    let!(:upload) { FactoryBot.create(:upload, :mixed_file_with_tar_gz) }

    it 'extracts files and copies non-tar files to a new upload' do
      expect do
        described_class.perform_now(upload)
      end.to change(upload.stream.uploads, :count).by(48)
    end
  end
end
