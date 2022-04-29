# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/index', type: :view do
  let(:org1) { create(:organization, name: 'Organization 1') }
  let(:org2) { create(:organization, name: 'Organization 2') }

  before do
    assign(:organizations, [org1, org2])
  end

  it 'renders a list of organizations' do
    render

    assert_select 'tr>td', text: 'Organization 1'
    assert_select 'tr>td', text: 'Organization 2'
  end

  it 'renders 2 charts' do
    render

    assert_select '#chart-1'
    assert_select '#chart-2'
  end

  it 'renders Destroy button if privileged' do
    allow(view).to receive(:can?).and_return(true)
    render

    assert_select 'a.btn', text: 'Destroy'
  end

  it 'renders Edit button if privileged' do
    allow(view).to receive(:can?).and_return(true)
    render

    assert_select 'a.btn', text: 'Edit'
  end

  it 'renders New organization button if privileged' do
    allow(view).to receive(:can?).and_return(true)
    render

    assert_select 'a.btn', text: 'New organization'
  end
end
