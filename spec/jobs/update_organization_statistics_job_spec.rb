# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateOrganizationStatisticsJob, type: :job do
  let(:organization) { create(:organization) }
  let(:first_upload) { build(:upload, :binary_marc) }
  let(:second_upload) { build(:upload, :binary_marc) }
  let(:third_upload) { build(:upload, :binary_marc) }

  before do
    organization.default_stream.uploads << first_upload
    organization.default_stream.uploads << second_upload
    organization.default_stream.uploads << third_upload

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

  it 'calculates statistics when there are no newer uploads' do
    described_class.perform_now(organization, organization.default_stream, third_upload)

    expect(organization.latest_statistics).to have_attributes(
      record_count: 3, unique_record_count: 1,
      file_count: 3, file_size: 4221
    )
  end

  it 'does not calculate statistics if there are newer uploads' do
    described_class.perform_now(organization, organization.default_stream, first_upload)
    expect(organization.statistics).to be_empty
  end
end
