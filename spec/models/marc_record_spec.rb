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

    before do
      organization.update(normalization_steps: { '0' => {
                            destination_tag: '998',
                            source_tag: '999',
                            subfields: { i: 'i', a: 'a', m: 'm' }
                          } })
    end

    it 'adds a $5 to indicate a POD-added field' do
      expect(marc_record.augmented_marc.fields('900').first['5']).to eq 'POD'
    end

    it "applies the Organization's code as the 900$b" do
      expect(marc_record.augmented_marc.fields('900').first['b']).to eq 'COOlCOdE'
    end

    it 'applies the organization normalization steps' do
      field = marc_record.augmented_marc.fields('998').first

      expect(field.subfields.map(&:to_s)).to include('$a NA737.K4 A4 1980 ')
        .and include('$i 36105032407764 ')
        .and include('$m ART ')
    end

    it 'includes provenance linking for derived data' do
      field = marc_record.augmented_marc.fields('998').first

      expect(field['8']).to eq '999.0\p'
    end
  end
end
