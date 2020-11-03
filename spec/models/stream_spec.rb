# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Stream, type: :model do
  subject(:stream) { described_class.new }

  describe '#display_name' do
    it 'defaults to the name of the stream' do
      stream.update(name: 'xyz')
      expect(stream.display_name).to eq 'xyz'
    end

    it 'defaults to the time span' do
      stream.update(created_at: Time.zone.parse('2020-11-01'), updated_at: Time.zone.parse('2020-11-05'))

      expect(stream.display_name).to eq '2020-11-01 - 2020-11-05'
    end

    it 'is open-ended if the stream is the default' do
      stream.update(created_at: Time.zone.parse('2020-11-01'), default: true)

      expect(stream.display_name).to eq '2020-11-01 - '
    end
  end

  describe '#removed_since_previous_stream' do
    pending 'returns a list of marc001 fields that have appeared in other organization streams except this one'
  end
end
