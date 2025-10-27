# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'uploading files to POD' do
  context 'with an organization user' do
    let(:organization) { create(:organization, name: 'Best University') }
    let(:stream) { create(:stream, organization: organization, status: 'default') }
    let(:user) { create(:user) }

    before do
      # first full dump: three records, 2020-05-06
      travel_to Time.zone.local(2020, 5, 6).beginning_of_day do
        create(:upload, :marc_xml, stream: stream)
        create(:upload, :marc_xml2, stream: stream)
        create(:upload, :binary_marc, stream: stream)
      end
      travel_to Time.zone.local(2020, 5, 6).end_of_day do
        GenerateFullDumpJob.perform_now(organization.default_stream)
      end

      user.add_role :owner, organization
      login_as(user, scope: :user)
    end

    describe 'MARC records' do
      it 'lists the MARC records for a stream' do
        visit organization_stream_url(organization, stream)

        click_on 'MARC records'

        expect(page).to have_css('tbody > tr', count: 3)

        fill_in 'marc001', with: 'a12345'
        click_on 'Search'

        expect(page).to have_css('tbody > tr', count: 1)
      end
    end
  end
end
