# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Stream, type: :model do
  subject(:stream) { create(:stream, organization: organization) }

  let(:organization) { create(:organization) }

  describe '#display_name' do
    it 'defaults to the name of the stream' do
      stream.update(name: 'xyz')
      expect(stream.display_name).to eq 'xyz'
    end

    it 'defaults to the time span' do
      # create Stream manually since factory provides display_name value
      expect(described_class.new(
        organization: organization,
        created_at: Time.zone.parse('2020-11-01'),
        updated_at: Time.zone.parse('2020-11-05')
      ).display_name).to eq '2020-11-01 - 2020-11-05'
    end

    it 'is open-ended if the stream is the default' do
      # create Stream manually since factory provides display_name value
      expect(described_class.new(
        organization: organization,
        created_at: Time.zone.parse('2020-11-01'),
        default: true
      ).display_name).to eq '2020-11-01 - '
    end
  end

  describe '#archive' do
    it 'sets status to archived' do
      stream.archive
      expect(stream.status).to eq 'archived'
    end

    it 'archives uploads' do
      organization = create(:organization)
      stream_with_upload = create(:stream_with_uploads, organization: organization)
      expect { stream_with_upload.archive }.to change { stream_with_upload.uploads.archived.count }.by(1)
    end
  end

  describe '#job_tracker_status_groups' do
    it 'groups the job trackers by status' do
      expect(stream.job_tracker_status_groups).to eq({ active: [], needs_attention: [] })
    end
  end

  describe '#make_default' do
    let!(:current_default) { create(:stream, organization: organization, default: true) }

    it 'makes the current stream the only default' do
      expect do
        stream.make_default
      end.to(change(stream, :default).from(false).to(true)
         .and((change { current_default.reload.default }).from(true).to(false)))
    end

    describe 'setting the default start and end times' do
      before do
        stream.make_default
        current_default.reload
      end

      it 'the new default stream has a start time' do
        expect(stream.default_start_time).to be_truthy
      end

      it 'the new default stream does not have an end time' do
        expect(stream.default_end_time).to be_nil
      end

      it 'the previous default stream has a start time' do
        expect(current_default.default_start_time).to be_truthy
      end

      it 'the previous default stream has an end time' do
        expect(current_default.default_end_time).to be_truthy
      end
    end

    it 'does not do anything if the stream is already the default' do
      expect { current_default.make_default }.not_to(change { current_default.reload.default })
    end
  end

  describe '#previous_default' do
    let!(:first_default) { create(:stream, organization: organization, default: true) }

    it 'returns nil if there is not a previous default stream' do
      expect(first_default.previous_default).to be_nil
    end

    it 'returns the previous default stream if it exists' do
      stream.make_default

      expect(stream.previous_default).to eq(first_default)
    end
  end
end
