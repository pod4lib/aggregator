# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcRecord, type: :model do
  subject(:marc_record) { described_class.new(file: upload.files.first, upload: upload, **attr) }

  let(:attr) { {} }
  let(:upload) { FactoryBot.create(:upload, :binary_marc) }

  describe '#marc' do
    let(:attr) { { bytecount: 0, length: 1407 } }

    it 'gets the MARC record from the file' do
      expect(marc_record.marc['001'].value).to eq 'a1297245'
    end

    context 'with a marcxml file' do
      let(:upload) { FactoryBot.create(:upload, :marc_xml) }
      let(:attr) { { index: 0 } }

      it 'gets the MARC record from the file by its index' do
        expect(marc_record.marc['001'].value).to eq 'a12345'
      end
    end

    context 'with a marc21 file that has been chunked for length' do
      let(:upload) { FactoryBot.create(:upload, :marc21_multi_record) }
      let(:attr) { { bytecount: 0, length: 99_999 } }

      it 'has the leader from the first record' do
        expect(marc_record.marc.leader).to eq '02269cas a2200421Ki 45 0'
      end

      it 'de-duplicates fields' do
        expect(marc_record.marc.fields('001').length).to eq 1
        expect(marc_record.marc.fields('001').first.value).to eq 'a9953670'
      end

      it 'merges fields from the second record' do
        expect(marc_record.marc.fields('863').length).to eq 8
      end
    end
  end
end
