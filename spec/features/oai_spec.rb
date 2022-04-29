# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAI-PMH', type: :feature do
  let(:organization) { create(:organization, name: 'My Org', slug: 'my-org') }
  let(:user) { create(:user) }

  # NOTE: capybara matchers don't always seem to work on returned XML documents;
  # parsing the response using Nokogiri is required for some assertions

  before do
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
  end

  context 'when the verb is Identify' do
    before do
      create(:upload, :marc_xml, stream: organization.default_stream, created_at: Date.new(2000, 10, 11))
      create(:upload, :marc_xml, stream: organization.default_stream, created_at: Date.new(2020, 5, 6))
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
    
    it 'renders the datestamp of the earliest item in the repository' do
      doc = Nokogiri::XML(page.body)
      expect(doc.at_css('Identify > earliestDatestamp').text).to eq('2000-10-11')
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
  end
end
