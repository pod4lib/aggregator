# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAI-PMH' do
  let(:organization) { create(:organization, :unrestricted, name: 'My Org', slug: 'my-org') }
  let(:user) { create(:user) }

  # NOTE: capybara matchers don't always seem to work on returned XML documents;
  # parsing the response using Nokogiri is required for some assertions

  before do
    # set a low oai_max_page_size so we get multiple oai-xml files generated
    allow(Settings).to receive(:oai_max_page_size).and_return(2)

    # first full dump: three records, 2020-05-06
    travel_to Time.zone.local(2020, 5, 6).beginning_of_day do
      create(:upload, :marc_xml, stream: organization.default_stream)
      create(:upload, :marc_xml2, stream: organization.default_stream)
      create(:upload, :binary_marc, stream: organization.default_stream)
    end
    travel_to Time.zone.local(2020, 5, 6).end_of_day do
      GenerateFullDumpJob.perform_now(organization.default_stream)
    end

    # delta dump from the next day, add one and delete one record
    travel_to Time.zone.local(2020, 5, 7).beginning_of_day do
      create(:upload, :marc_xml3, stream: organization.default_stream)
      create(:upload, :deleted_marc_xml, stream: organization.default_stream)
    end
    travel_to Time.zone.local(2020, 5, 7).end_of_day do
      GenerateDeltaDumpJob.perform_now(organization.default_stream)
    end

    # required for API access
    user.add_role :member, organization
    login_as(user, scope: :user)
  end

  it 'renders responses with a utf-8 xml content type' do
    visit oai_path
    expect(page.response_headers['Content-Type']).to eq('application/xml; charset=utf-8')
  end

  it 'renders an error if no verb is supplied' do
    visit oai_path
    expect(page).to have_css('error[code="badVerb"]')
  end

  it 'renders an error if an unknown verb is supplied' do
    visit oai_path(verb: 'Oops')
    expect(page).to have_css('error[code="badVerb"]')
  end

  it 'renders the time the request was submitted in iso8601 format' do
    visit oai_path
    doc = Nokogiri::XML(page.body)
    expect(doc.at_css('responseDate').content).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
  end

  it 'renders the request params and root url as an element' do
    visit oai_path(verb: 'ListSets')
    expect(page).to have_css('request[verb="ListSets"]', text: oai_url)
  end

  context 'when the verb is ListSets' do
    it 'renders a name for each set' do
      visit oai_path(verb: 'ListSets')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListSets > set > setName').text).to eq('2020-05-06 - ')
    end

    it 'renders an identifier (setSpec) for each set' do
      visit oai_path(verb: 'ListSets')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListSets > set > setSpec').text).to eq(organization.default_stream.id.to_s)
    end

    it 'renders a description for each set' do
      visit oai_path(verb: 'ListSets')
      expect(page).to have_text('Default stream for My Org, 2020-05-06/')
    end

    it 'renders an error if unknown params are supplied' do
      visit oai_path(verb: 'ListSets', foo: 'bar')
      expect(page).to have_css('error[code="badArgument"]')
    end
  end

  context 'when the verb is Identify' do
    before do
      visit oai_path(verb: 'Identify')
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
      visit oai_path(verb: 'Identify', foo: 'bar')
      expect(page).to have_css('error[code="badArgument"]')
    end
  end

  context 'when the verb is ListMetadataFormats' do
    it 'renders all metadata formats supported by the repository' do
      visit oai_path(verb: 'ListMetadataFormats')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListMetadataFormats > metadataFormat > metadataPrefix').text).to eq('marc21')
      expect(doc.at_css('ListMetadataFormats > metadataFormat > schema').text).to eq('http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd')
      expect(doc.at_css('ListMetadataFormats > metadataFormat > metadataNamespace').text).to eq('http://www.loc.gov/MARC21/slim')
    end

    it 'renders the metadata formats available for a single item' do
      visit oai_path(verb: 'ListMetadataFormats', identifier: 'oai:pod.stanford.edu:my-org:1:a12345')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListMetadataFormats > metadataFormat > metadataPrefix').text).to eq('marc21')
    end

    it 'renders an error if an unknown identifier is supplied' do
      pending 'single item requests are not yet implemented'
      visit oai_path(verb: 'ListMetadataFormats', identifier: 'fake')
      expect(page).to have_css('error[code="idDoesNotExist"]')
    end

    it 'renders an error if unknown params are supplied' do
      visit oai_path(verb: 'ListMetadataFormats', foo: 'bar')
      expect(page).to have_css('error[code="badArgument"]')
    end
  end

  context 'when the verb is ListRecords' do
    it 'renders the identifier of each item' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListRecords > record > header > identifier').text).to(
        eq('oai:pod.stanford.edu:my-org:a12345')
      )
    end

    it 'renders the datestamp of each item' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListRecords > record > header > datestamp').text).to eq('2020-05-06')
    end

    it 'renders a header indicating records are deleted' do
      token = OaiConcern::ResumptionToken.new(set: organization.default_stream.id.to_s, page: '2')
      visit oai_path(verb: 'ListRecords', resumptionToken: token.encode)
      expect(page).to have_css('header[status="deleted"]')
    end

    it 'renders the set membership of each item' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListRecords > record > header > setSpec').text).to eq(organization.default_stream.id.to_s)
    end

    it 'renders records in the requested set' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21', set: organization.default_stream.id.to_s)
      doc = Nokogiri::XML(page.body)
      doc.css('ListRecords > record > header > setSpec').each do |record_set|
        expect(record_set.text).to eq(organization.default_stream.id.to_s)
      end
    end

    it 'renders a resumption token to continue requesting records if needed' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21', set: organization.default_stream.id.to_s)
      doc = Nokogiri::XML(page.body)
      token = OaiConcern::ResumptionToken.decode(doc.at_css('ListRecords > resumptionToken').text)
      expect(token.set.to_i).to be(organization.default_stream.id)
      expect(token.page.to_i).to be(1)
    end

    it 'does not render a resumption token if there is only one page of results' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21', from: '2020-05-07')
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('ListRecords > resumptionToken')).to be_nil
    end

    it 'renders records after a supplied lower bound datestamp' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21', from: '2020-05-07')
      doc = Nokogiri::XML(page.body)
      doc.css('ListRecords > record > header > datestamp').each do |record_ds|
        expect(record_ds.text).to be >= '2020-05-07'
      end
    end

    it 'renders records before a supplied upper bound datestamp' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21', until: '2020-05-06')
      doc = Nokogiri::XML(page.body)
      doc.css('ListRecords > record > header > datestamp').each do |record_ds|
        expect(record_ds.text).to be <= '2020-05-06'
      end
    end

    it 'renders an error if unknown params are supplied' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21', foo: 'bar')
      expect(page).to have_css('error[code="badArgument"]')
    end

    it 'renders an error if no metadata prefix is supplied' do
      visit oai_path(verb: 'ListRecords')
      expect(page).to have_css('error[code="badArgument"]')
    end

    it 'renders an error if an unsupported metadata prefix is supplied' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'foo')
      expect(page).to have_css('error[code="cannotDisseminateFormat"]')
    end

    it 'renders an error if the request results in an empty result set' do
      visit oai_path(verb: 'ListRecords', metadataPrefix: 'marc21', set: '392487')
      expect(page).to have_css('error[code="noRecordsMatch"]')
    end

    context 'when a resumption token is supplied' do
      it 'renders the indicated page of records' do
        visit oai_path(verb: 'ListRecords', resumptionToken: OaiConcern::ResumptionToken.new(page: '2').encode)
        expect(page).to have_text('oai:pod.stanford.edu:my-org:DUKE000075163')
      end

      it 'renders an error if any other argument is also supplied' do
        visit oai_path(verb: 'ListRecords', resumptionToken: OaiConcern::ResumptionToken.new(set: '1').encode, from: '2020-01-01')
        expect(page).to have_css('error[code="badArgument"]')
      end

      it 'renders an error if the resumption token is not valid' do
        visit oai_path(verb: 'ListRecords', resumptionToken: 'foo')
        expect(page).to have_css('error[code="badResumptionToken"]')
      end

      it 'renders an error if the requested page of records does not exist' do
        visit oai_path(verb: 'ListRecords', resumptionToken: OaiConcern::ResumptionToken.new(page: '999').encode)
        expect(page).to have_css('error[code="badResumptionToken"]')
      end
    end
  end
end
