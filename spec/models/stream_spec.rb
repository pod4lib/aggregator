# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Stream, type: :model do
  subject(:stream) { described_class.new }

  describe '#display_name' do
    it 'defaults to the name of the stream' do
      stream.update(name: 'xyz')
      expect(stream.display_name).to eq 'xyz'
    end

    it 'defaults to the time span' do
      stream.update(created_at: Time.zone.parse('2020-11-01'), updated_at: Time.zone.parse('2020-11-05'))

      expect(stream.display_name).to eq '2020-11-01 - 2020-11-05'
    end

    it 'is open-ended if the stream is the default' do
      stream.update(created_at: Time.zone.parse('2020-11-01'), default: true)

      expect(stream.display_name).to eq '2020-11-01 - '
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

  describe '#default_stream_histories' do
    it 'creates a default stream history when the first stream is created in an organization' do
      org = create(:organization)
      described_class.create({ organization: org, default: true })
      described_class.create({ organization: org, default: true })
      expect(org.default_stream_histories.count).to be(1)
    end

    it 'creates a new default stream history when stream becomes the default' do
      org = create(:organization)
      first_stream = described_class.create({ organization: org, default: true })
      second_stream = described_class.create({ organization: org, default: false })
      
      second_stream.update(default: true)
      expect(DefaultStreamHistory.all[1].end_time).to be(nil)
    end

    it 'updates and appends endtime to prior default stream history when the stream is no longer the default' do
      org = create(:organization)
      first_stream = described_class.create({ organization: org, default: true })
      second_stream = described_class.create({ organization: org, default: false })

      first_stream.update(default: false)
      expect(DefaultStreamHistory.all[0].end_time).not_to be(nil)
    end
  end
end
