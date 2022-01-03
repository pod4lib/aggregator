# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JobTracker, type: :model do
  subject(:job_tracker) { described_class.new(attributes.merge(job_class: 'whatever', job_id: job_id)) }

  let(:attributes) { {} }
  let(:status_attributes) { { progress: 50, total: 100 } }
  let(:job_id) { 'job_id' }

  before do
    allow(ActiveJob::Status).to receive(:get).with(job_id).and_return(status_attributes)
  end

  describe '#label' do
    context 'with a blob' do
      let(:attributes) { { resource: build(:upload, :binary_marc).files.first.blob } }

      it 'includes the file name' do
        expect(job_tracker.label).to eq '[Whatever] 1297245.marc'
      end
    end

    context 'with an upload' do
      let(:attributes) { { resource: build(:upload, name: 'zzz') } }

      it 'includes the upload name' do
        expect(job_tracker.label).to eq '[Whatever] zzz'
      end
    end
  end

  describe '#status' do
    it 'retrieves the status' do
      expect(job_tracker.status).to eq status_attributes
    end
  end

  describe '#progress_label' do
    let(:status_attributes) { { progress: 5000, total: 12_345 } }

    it 'returns the current progress' do
      expect(job_tracker.progress_label).to eq '5,000 / 12,345'
    end

    context 'without a final total' do
      let(:status_attributes) { { progress: 5000 } }

      it 'just shows the current progress' do
        expect(job_tracker.progress_label).to eq '5,000'
      end
    end
  end

  describe '#progress' do
    let(:status_attributes) { { progress: 50 } }

    it 'returns the current progress' do
      expect(job_tracker.total).to eq 50
    end
  end

  describe '#total' do
    context 'with no total' do
      let(:status_attributes) { { progress: 50 } }

      it 'returns the current progress' do
        expect(job_tracker.total).to eq 50
      end
    end
  end

  describe '#total?' do
    subject(:total) { job_tracker.total? }

    let(:status_attributes) { { total: 100 } }

    it { is_expected.to eq true }

    context 'with an unknown or 0 total' do
      let(:status_attributes) { { total: 0 } }

      it { is_expected.to eq false }
    end
  end

  describe '#percent' do
    subject(:percent) { job_tracker.percent }

    context 'with an unknown or 0 total' do
      let(:status_attributes) { { total: 0 } }

      it { is_expected.to be_nil }
    end

    it { is_expected.to eq 50 }
  end
end
