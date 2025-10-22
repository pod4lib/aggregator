# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group do
  let(:group) { create(:group) }
  let(:organization) { create(:organization) }

  describe '#display_name' do
    context 'when short_name is present' do
      it 'returns the short_name' do
        group.short_name = 'Short Name'
        expect(group.display_name).to eq 'Short Name'
      end
    end

    context 'when short_name is blank' do
      it 'returns the name' do
        group.short_name = ''
        group.name = 'Full Name'
        expect(group.display_name).to eq 'Full Name'
      end
    end
  end
end
