# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcRecord, type: :model do
  subject(:marc_record) { described_class.new(file: upload.files.first, upload: upload, **attr) }

  let(:attr) { {} }
  let(:organization) { FactoryBot.create(:organization, code: 'COOlCOdE') }
  let(:upload) { FactoryBot.create(:upload, :binary_marc, organization: organization) }

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
  end

  describe '#augmented_marc' do
    let(:attr) { { bytecount: 0, length: 1407 } }

    it "applies the Organization's code as the 900$b" do
      expect(marc_record.augmented_marc.fields('900').first['b']).to eq 'COOlCOdE'
    end
  end
end
