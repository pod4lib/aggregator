# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomMarcWriter do
  let(:long_upload) { create(:upload, :long_file) }
  let(:split_marc_records) do
    MARC::Reader.new(
      StringIO.new(
        described_class.encode(long_upload.each_marc_record_metadata.first.marc)
      )
    ).to_a
  end

  describe 'encode' do
    it 'splits up long marc records' do
      expect(split_marc_records.length).to eq 2
      split_marc_records.each do |record|
        expect(record.fields('001').first.value).to eq 'DUKE000132268'
      end
    end
  end
end
