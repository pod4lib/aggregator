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
end
