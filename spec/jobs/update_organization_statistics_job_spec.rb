# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateOrganizationStatisticsJob do
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

  it 'calculates stream-level statistics' do
    described_class.perform_now(organization.default_stream)

    expect(organization.default_stream.statistic).to have_attributes(
      record_count: 3, unique_record_count: 1,
      file_count: 3, file_size: 4221
    )
  end
end
