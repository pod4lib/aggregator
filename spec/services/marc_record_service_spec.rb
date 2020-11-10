# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcRecordService do
  subject(:service) { described_class.new(blob) }

  context 'with a marc21 file' do
    let(:upload) { FactoryBot.create(:upload, :binary_marc) }
    let(:blob) { upload.files.first.blob }

    it { is_expected.to be_marc21 }

    describe '#identify' do
      it 'is identified as marc21' do
        expect(service.identify).to eq :marc21
      end
    end

    describe '#count' do
      it 'is 1' do
        expect(service.count).to eq 1
      end
    end

    describe '#at_index' do
      it 'extracts the record at the given index' do
        expect(service.at_index(0)['001'].value).to eq 'a1297245'
      end
    end

    describe '#at_bytes' do
      it 'extracts the record at the given byte range' do
        expect(service.at_bytes(0...1407).first['001'].value).to eq 'a1297245'
      end
    end

    describe '#each_with_metadata' do
      it 'includes information about the byte position' do
        _record, metadata = service.each_with_metadata.first
        expect(metadata).to include bytecount: 0, length: 1407, index: 0
      end
    end
  end

  context 'with a marcxml file' do
    let(:upload) { FactoryBot.create(:upload, :marc_xml) }
    let(:blob) { upload.files.first.blob }

    it { is_expected.not_to be_marc21 }

    describe '#identify' do
      it 'is identified as marcxml' do
        expect(service.identify).to eq :marcxml
      end
    end

    describe '#count' do
      it 'is 1' do
        expect(service.count).to eq 1
      end
    end

    describe '#at_index' do
      it 'extracts the record at the given index' do
        expect(service.at_index(0)['001'].value).to eq 'a12345'
      end
    end

    describe '#each_with_metadata' do
      it 'includes information about the index' do
        _record, metadata = service.each_with_metadata.first
        expect(metadata).to include index: 0
      end
    end
  end
end
