# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OxMarcXmlWriter do
  let(:record) do
    record1 = MARC::Record.new
    record1.leader = '00925njm  22002777a 4500'
    record1.append MARC::ControlField.new('007', 'sdubumennmplu')
    record1.append MARC::DataField.new('245', '0', '4',
                                       ['a', 'The Great Ray Charles'], ['h', '[sound recording].'])
    record1.append MARC::DataField.new('998', ' ', ' ',
                                       ['^', 'Valid local subfield'])

    record1
  end

  it 'writes the same as MARC::XMLWriter' do
    stringio = StringIO.new
    writer = described_class.new(stringio)
    writer.write(record)
    writer.close

    expect(MARC::XMLReader.new(StringIO.new(stringio.string)).first).to eq(record)
  end
end
