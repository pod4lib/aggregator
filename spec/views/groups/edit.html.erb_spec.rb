# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'groups/edit' do
  let(:group) { create(:group) }

  before do
    assign(:group, group)
    render
  end

  it 'renders edit group form' do
    assert_select 'form[action=?][method=?]', group_path(group), 'post' do
      assert_select 'input[name=?]', 'group[name]'
      assert_select 'input[name=?]', 'group[short_name]'
      assert_select 'input[name=?]', 'group[slug]'
    end
  end
end
