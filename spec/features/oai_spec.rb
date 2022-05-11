# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAI-PMH', type: :feature do
  let(:organization) { create(:organization, name: 'My Org', slug: 'my-org') }
  let(:user) { create(:user) }

  # NOTE: capybara matchers don't always seem to work on returned XML documents;
  # parsing the response using Nokogiri is required for some assertions

  before do
    # first full dump: two records, 2020-05-06
    travel_to Time.zone.local(2020, 5, 6) do
      create(:upload, :marc_xml, stream: organization.default_stream)
      create(:upload, :binary_marc, stream: organization.default_stream)
      GenerateFullDumpJob.perform_now(organization)
    end

    # delta dump from the next day, with one of the records deleted
    travel_to Time.zone.local(2020, 5, 7) do
      create(:upload, :deleted_marc_xml, stream: organization.default_stream)
      GenerateDeltaDumpJob.perform_now(organization)
    end

    # required for API access
    user.add_role :member, organization
    login_as(user, scope: :user)
  end

  it 'renders responses with a utf-8 xml content type' do
    visit oai_url
    expect(page.response_headers['Content-Type']).to eq('application/xml; charset=utf-8')
  end

  it 'renders an error if no verb is supplied' do
    visit oai_url
    expect(page).to have_selector('error[code="badVerb"]')
  end

  it 'renders an error if an unknown verb is supplied' do
    visit oai_url(verb: 'Oops')
    expect(page).to have_selector('error[code="badVerb"]')
  end

  it 'renders the time the request was submitted in iso8601 format' do
    visit oai_url
    doc = Nokogiri::XML(page.body)
    expect(doc.at_css('responseDate').content).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
  end

  it 'renders the request params and root url as an element' do
    visit oai_url(verb: 'ListSets')
    expect(page).to have_selector('request[verb="ListSets"]', text: oai_url)
  end

  context 'when the verb is ListSets' do
    it 'renders a set element for each organization' do
      visit oai_url(verb: 'ListSets')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListSets > set > setName').text).to eq('My Org')
      expect(doc.at_css('ListSets > set > setSpec').text).to eq('my-org')
    end

    it 'renders an error if unknown params are supplied' do
      visit oai_url(verb: 'ListSets', foo: 'bar')
      expect(page).to have_selector('error[code="badArgument"]')
    end
  end

  context 'when the verb is Identify' do
    before do
      visit oai_url(verb: 'Identify')
    end

    it 'renders the repository name' do
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('Identify > repositoryName').text).to eq('POD Aggregator')
    end

    it 'renders the repository base url' do
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('Identify > baseURL').text).to eq(oai_url)
    end

    it 'renders the repository protocol version' do
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('Identify > protocolVersion').text).to eq('2.0')
    end

    it 'renders the datestamp of the earliest OAI-XML dump' do
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('Identify > earliestDatestamp').text).to eq('2020-05-06')
    end

    it 'renders the type of support for deleted records' do
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('Identify > deletedRecord').text).to eq('transient')
    end

    it 'renders the harvesting granularity' do
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('Identify > granularity').text).to eq('YYYY-MM-DD')
    end

    it 'renders the repository administrative email' do
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('Identify > adminEmail').text).to eq('pod-support@lists.stanford.edu')
    end

    it 'renders an error if unknown params are supplied' do
      visit oai_url(verb: 'Identify', foo: 'bar')
      expect(page).to have_selector('error[code="badArgument"]')
    end
  end

  context 'when the verb is ListMetadataFormats' do
    it 'renders all metadata formats supported by the repository' do
      visit oai_url(verb: 'ListMetadataFormats')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListMetadataFormats > metadataFormat > metadataPrefix').text).to eq('marc21')
      expect(doc.at_css('ListMetadataFormats > metadataFormat > schema').text).to eq('http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd')
      expect(doc.at_css('ListMetadataFormats > metadataFormat > metadataNamespace').text).to eq('http://www.loc.gov/MARC21/slim')
    end

    it 'renders the metadata formats available for a single item'

    it 'renders an error if an unknown identifier is supplied'

    it 'renders an error if no metadata formats are available for the item'

    it 'renders an error if unknown params are supplied' do
      visit oai_url(verb: 'ListMetadataFormats', foo: 'bar')
      expect(page).to have_selector('error[code="badArgument"]')
    end
  end

  context 'when the verb is ListRecords' do
    it 'renders the identifier of each item' do
      visit oai_url(verb: 'ListRecords', metadataPrefix: 'marc21')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListRecords > record > header > identifier').text).to eq('oai:pod.stanford.edu:my-org:a12345')
    end

    it 'renders the datestamp of each item' do
      visit oai_url(verb: 'ListRecords', metadataPrefix: 'marc21')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListRecords > record > header > datestamp').text).to eq('2020-05-06')
    end

    it 'renders a header indicating records are deleted' do
      pending('There should be a deleted record, but it is not on the first page.')
      visit oai_url(verb: 'ListRecords', metadataPrefix: 'marc21')
      expect(page).to have_selector('header[status="deleted"]')
    end

    it 'renders the set membership of each item' do
      visit oai_url(verb: 'ListRecords', metadataPrefix: 'marc21')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListRecords > record > header > setSpec').text).to eq('my-org')
    end

    it 'renders records in the requested set'

    it 'renders a resumption token to continue requesting records'

    # NOTE: mock OAIPMHWriter::max_records_per_file to a very low number,
    # then run the GenerateFullDump/GenerateDeltaDump jobs so that we
    # generate many (very small) OAI-XML files. This will make it easier
    # to test that the paging/resumption tokens work as expected

    it 'renders records after a supplied lower bound datestamp'

    it 'renders records before a supplied upper bound datestamp'

    it 'renders an error if unknown params are supplied' do
      visit oai_url(verb: 'ListRecords', metadataPrefix: 'marc21', foo: 'bar')
      expect(page).to have_selector('error[code="badArgument"]')
    end

    it 'renders an error if no metadata prefix is supplied' do
      visit oai_url(verb: 'ListRecords')
      expect(page).to have_selector('error[code="badArgument"]')
    end

    it 'renders an error if an unsupported metadata prefix is supplied' do
      visit oai_url(verb: 'ListRecords', metadataPrefix: 'foo')
      expect(page).to have_selector('error[code="cannotDisseminateFormat"]')
    end

    context 'when a resumption token is supplied' do
      it 'renders the next page of records'
      it 'renders an error if any other argument is also supplied' do
        visit oai_url(verb: 'ListRecords', from: '2020-01-01', resumptionToken: 'foo')
        expect(page).to have_selector('error[code="badArgument"]')
      end

      it 'renders an error if the resumption token is not valid' do
        pending('badResumptionToken only gets raised if the page count is out of range. ' \
                'Need to improve token error handling before this test will pass.')
        visit oai_url(verb: 'ListRecords', resumptionToken: 'foo')
        expect(page).to have_selector('error[code="badResumptionToken"]')
      end
    end
  end
end
