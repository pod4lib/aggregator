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

  context 'with a gzipped marc21 file' do
    let(:upload) { FactoryBot.create(:upload, :small_batch_gz) }
    let(:blob) { upload.files.first.blob }

    it { is_expected.to be_marc21 }

    describe '#identify' do
      it 'is identified as marc21_gzip' do
        expect(service.identify).to eq :marc21_gzip
      end
    end

    describe '#count' do
      it 'is 50' do
        expect(service.count).to eq 50
      end
    end

    describe '#at_index' do
      it 'extracts the record at the given index' do
        expect(service.at_index(3)['001'].value).to eq 'a500003'
      end
    end

    describe '#at_bytes' do
      it 'extracts the record at the given byte range' do
        expect(service.at_bytes(17_700...(17_700 + 1133)).first['001'].value).to eq 'a500016'
      end
    end

    describe '#each_with_metadata' do
      it 'includes information about the byte position' do
        _record, metadata = service.each_with_metadata.first
        expect(metadata).to include bytecount: 0, length: 1068, index: 0
      end
    end
  end

  context 'with a MARC21 record that has been chunked' do
    let(:upload) { FactoryBot.create(:upload, :marc21_multi_record) }
    let(:blob) { upload.files.first.blob }

    it { is_expected.to be_marc21 }

    describe '#count' do
      it 'is 2' do
        expect(service.count).to eq 2
      end
    end

    describe '#each' do
      it 'combines records based on repeated 001 fields' do
        expect(service.each.count).to eq 1
      end
    end

    it 'has the leader from the first record' do
      record = service.each.first
      expect(record.leader).to eq '02269cas a2200421Ki 45 0'
    end

    it 'de-duplicates fields' do
      record = service.each.first
      expect(record.fields('001').length).to eq 1
      expect(record.fields('001').first.value).to eq 'a9953670'
    end

    it 'merges fields from the second record' do
      record = service.each.first
      expect(record.fields('863').length).to eq 8
    end

    it 'merges the metadata information' do
      _record, metadata = service.each_with_metadata.first
      expect(metadata).to include length: 2269 + 518, checksum: '07a51130b70560cf5240e1e2c6c35b33'
    end
  end
end
