# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateOrganizationStatisticsJob, type: :job do
  let(:organization) { create(:organization) }

  before do
    organization.default_stream.uploads << build(:upload, :binary_marc)
    organization.default_stream.uploads << build(:upload, :binary_marc)
    organization.default_stream.uploads << build(:upload, :binary_marc)

    # populate the MarcRecords index
    organization.default_stream.uploads.each { |u| ExtractMarcRecordMetadataJob.perform_now(u) }
  end

  it 'calculates organization-level statistics' do
    described_class.perform_now(organization)

    expect(organization.latest_statistics).to have_attributes(
      record_count: 3, unique_record_count: 1,
      file_count: 3, file_size: 4221
    )
  end

  it 'calculates stream-level statistics' do
    described_class.perform_now(organization)

    expect(organization.default_stream.statistic).to have_attributes(
      record_count: 3, unique_record_count: 1,
      file_count: 3, file_size: 4221
    )
  end
end
