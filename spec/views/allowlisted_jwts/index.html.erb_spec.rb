# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'allowlisted_jwts/index', type: :view do
  let(:organization) { FactoryBot.build(:organization) }

  before do
    assign(:organization, organization)
    assign(:allowlisted_jwts, [
             organization.allowlisted_jwts.build(jti: 'abc'),
             organization.allowlisted_jwts.build(jti: 'xyz')
           ])
  end

  it 'renders a list of tokens for the organizations' do
    render
    assert_select 'tbody>tr', count: 2
    assert_select 'input[value=?]', organization.allowlisted_jwts[0].encoded_token
    assert_select 'input[value=?]', organization.allowlisted_jwts[1].encoded_token
  end
end
