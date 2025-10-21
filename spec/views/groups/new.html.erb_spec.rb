# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'groups/new' do
  before do
    assign(:group, Group.new)
    render
  end

  it 'renders new group form' do
    assert_select 'form[action=?][method=?]', groups_path, 'post' do
      assert_select 'input[name=?]', 'group[name]'
      assert_select 'input[name=?]', 'group[short_name]'
      assert_select 'input[name=?]', 'group[slug]'
    end
  end
end
