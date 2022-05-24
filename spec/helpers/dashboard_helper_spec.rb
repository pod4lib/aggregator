# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardHelper, type: :helper do
  let(:organization) { create(:organization) }
  let(:stream) { create(:stream, organization: organization) }
  let(:uploads) do
    [
      create(:upload, :binary_marc, stream: stream),
      create(:upload, :multiple_files, stream: stream),
      create(:upload, :binary_marc, stream: stream),
      create(:upload, :binary_marc, stream: stream)
    ]
  end

  before do
    # uploads[0]: Create successful upload metadata. Archive the upload (makes the upload no longer active)
    uploads[0].files.first.metadata = { 'identified' => true, 'analyzer' => 'MarcAnalyzer', 'count' => 1, 'type' => 'marc21',
                                        'analyzed' => true }
    uploads[0].archive

    # uploads[1]: Create mixed success/fail upload metadata. Archive the upload
    uploads[1].files[0].metadata = { 'identified' => true, 'analyzer' => 'MarcAnalyzer', 'count' => 1, 'type' => 'marc21',
                                     'analyzed' => true }
    uploads[1].files[1].metadata = { 'identified' => true, 'analyzer' => 'fake', 'count' => 1, 'analyzed' => true }
    uploads[1].archive

    # uploads[2]: Don't set any metadata so it defaults to fail. Archive the upload
    uploads[2].archive

    # uploads[3]: implicitly active since we do not archive it
  end

  describe '#files_status' do
    it 'returns completed status for valid uploads that are not active' do
      expect(helper.files_status(uploads[0])).to eq(:completed)
    end

    it 'returns needs_attention status for mixed uploads that are not active' do
      expect(helper.files_status(uploads[1])).to eq(:needs_attention)
    end

    it 'returns failed status for bad uploads that are not active' do
      expect(helper.files_status(uploads[2])).to eq(:failed)
    end

    it 'returns active status for active uploads' do
      expect(helper.files_status(uploads[3])).to eq(:active)
    end
  end

  describe '#best_status' do
    it 'returns the best status out of a group of non-active uploads' do
      # the first 3 uploads in the array are archived/non-active
      expect(helper.best_status(uploads.first(3))).to eq(:completed)
    end
  end

  describe '#last_successful_upload_date' do
    it 'returns the date of the most recent successful upload' do
      expect(helper.last_successful_upload_date(uploads)).to eq(uploads[0].created_at)
    end
  end
end
