# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StreamsJobStatusComponent, type: :component do
  subject(:component) { described_class.new(stream:) }

  let(:stream) { create(:stream, organization:) }
  let(:organization) { create(:organization) }

  it 'applies class to show tab when tab expanded is false and job count is positive' do
    set_tab_class = component.job_status_tabs_collapse(false, 3)
    expect(set_tab_class).to be('show')
  end

  it 'applies class to collapse tab when tab expanded is true and job count is positive' do
    set_tab_class = component.job_status_tabs_collapse(true, 3)
    expect(set_tab_class).to be('collapsed')
  end

  it 'applies class to collapse tab when tab expanded is true and job count is zero' do
    set_tab_class = component.job_status_tabs_collapse(true, 0)
    expect(set_tab_class).to be('collapsed')
  end

  it 'applies class to collapse tab when tab expanded is false and job count is zero' do
    set_tab_class = component.job_status_tabs_collapse(false, 0)
    expect(set_tab_class).to be('collapsed')
  end
end
