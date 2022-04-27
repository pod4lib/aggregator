# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateInterstreamDeltaJob, type: :job do
	let(:organization) { create(:organization) }

	before do
    	organization.default_stream.uploads << build(:upload, :binary_marc)
		organization.default_stream.uploads << build(:upload, :long_file)
		organization.default_stream.uploads << build(:upload, :binary_marc)
  	end

	it 'Does not create an interstream delta if there is no previous default stream' do
		GenerateFullDumpJob.perform_now(organization)
		described_class.perform_now(organization.default_stream)
		expect(organization.default_stream.current_full_dump.interstream_delta).to be(nil)
	end

	# test for no result on no existing dump for previous stream
	# test for no result on no existing dump for current stream
end