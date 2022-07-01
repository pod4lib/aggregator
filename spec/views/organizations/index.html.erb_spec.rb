# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/index', type: :view do
  let(:org1) { create(:organization, name: 'Organization 1') }
  let(:org2) { create(:organization, name: 'Organization 2') }
  let(:org3) { create(:organization, name: 'Organization 3', provider: false) }
  let(:org4) { create(:organization, name: 'Organization 4', provider: false) }

  before do
    assign(:providers, [org1, org2])
    assign(:consumers, [org3, org4])
  end

  it 'renders a list of providers' do
    allow(view).to receive(:can?).and_return(true)
    render

    assert_select '#providers tr>td', text: 'Organization 1'
    assert_select '#providers tr>td', text: 'Organization 2'
  end

  it 'renders a list of consumers for admins' do
    sign_in create(:admin)
    render

    assert_select '#consumers tr>td', text: 'Organization 3'
    assert_select '#consumers tr>td', text: 'Organization 4'
  end

  it 'renders 2 charts' do
    render

    assert_select '#chart-1'
    assert_select '#chart-2'
  end

  it 'renders Delete button if privileged' do
    allow(view).to receive(:can?).and_return(true)
    render

    assert_select 'a.btn', text: 'Delete'
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
