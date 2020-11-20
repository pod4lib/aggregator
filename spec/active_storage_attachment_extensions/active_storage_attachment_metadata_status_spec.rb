# frozen_string_literal: true

require 'spec_helper'
require 'active_storage_attachment_metadata_status'

def stub_class
  Class.new do
    attr_reader :metadata

    def initialize(metadata)
      @metadata = metadata
    end
    include ActiveStorageAttachmentMetadataStatus
  end
end

RSpec.describe ActiveStorageAttachmentMetadataStatus do
  let(:metadata) { {} }
  let(:test_class) { stub_class.new(metadata) }

  describe '#pod_metadata_status' do
    context 'when the MARC analyzer as marked it as invalid' do
      let(:metadata) { { 'analyzer' => 'MarcAnalyzer', 'valid' => false } }

      it { expect(test_class.pod_metadata_status).to eq :invalid }
    end

    context 'when an analyzer other than the MARC analyzer has processed the file' do
      let(:metadata) { { 'analyzer' => 'ImageAnalyzer', 'identified' => true, 'analyzed' => true } }

      it { expect(test_class.pod_metadata_status).to eq :not_marc }
    end

    context 'when the MarcAnalyzer has successfully analyzed the file' do
      let(:metadata) { { 'analyzer' => 'MarcAnalyzer', 'analyzed' => true } }

      it { expect(test_class.pod_metadata_status).to eq :success }
    end

    context 'with no metadata' do
      it { expect(test_class.pod_metadata_status).to eq :unknown }
    end
  end
end
