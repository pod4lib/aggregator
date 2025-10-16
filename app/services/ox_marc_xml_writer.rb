# frozen_string_literal: true

# Write MARC records to XML using Ox instead of REXML (from upstream)
class OxMarcXmlWriter < MARC::XMLWriter
  def initialize(file, opts = {}, &)
    super
  end

  def write(record)
    @fh.puts(Ox.dump(OxMarcXmlWriter.encode(record)))
    @fh.write("\n")
  end

  # a static method that accepts a MARC::Record object
  # and returns a Ox::Element for the XML serialization.
  def self.encode(record, opts = {}) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    single_char = Regexp.new('[\da-z ]{1}')
    subfield_char = Regexp.new('[\dA-Za-z!"#$%&\'()*+,-./:;<=>?{}_^`~\[\]\\\]{1}')
    control_field_tag = Regexp.new('00[1-9A-Za-z]{1}')

    # Right now, this writer handles input from the strict and
    # lenient MARC readers. Because it can get 'loose' MARC in, it
    # attempts to do some cleanup on data values that are not valid
    # MARCXML.

    # TODO? Perhaps the 'loose MARC' checks should be split out
    # into a tolerant MARCXMLWriter allowing the main one to skip
    # this extra work.

    # TODO: At the very least there should be some logging
    # to record our attempts to account for less than perfect MARC.

    e = Ox::Element.new('record')
    e[:xmlns] = MARC::MARC_NS if opts[:include_namespace]

    leader_element = Ox::Element.new('leader')
    leader_element << fix_leader(record.leader)
    e << leader_element

    record.each do |field| # rubocop:disable Metrics/BlockLength
      if field.instance_of?(MARC::DataField)
        datafield_elem = Ox::Element.new('datafield')

        ind1 = field.indicator1
        # If marc is leniently parsed, we may have some dirty data; using
        # the 'z' ind1 value should help us locate these later to fix
        ind1 = 'z' if ind1.nil? || !ind1.match?(single_char)
        ind2 = field.indicator2
        # If marc is leniently parsed, we may have some dirty data; using
        # the 'z' ind2 value should help us locate these later to fix

        ind2 = 'z' if field.indicator2.nil? || !ind2.match?(single_char)

        datafield_elem[:tag] = field.tag
        datafield_elem[:ind1] = ind1
        datafield_elem[:ind2] = ind2

        field.subfields.each do |subfield|
          subfield_element = Ox::Element.new('subfield')

          code = subfield.code
          # If marc is leniently parsed, we may have some dirty data; using
          # the blank subfield code should help us locate these later to fix
          code = ' ' if subfield.code.match(subfield_char).nil?

          subfield_element['code'] = code
          text = subfield.value
          subfield_element << text
          datafield_elem << subfield_element
        end

        e << datafield_elem
      elsif field.instance_of?(MARC::ControlField)
        control_element = Ox::Element.new('controlfield')

        tag = field.tag
        # We need a marker for invalid tag values (we use 000)
        tag = '00z' unless tag.match(control_field_tag) || MARC::ControlField.control_tag?(tag)

        control_element['tag'] = tag
        text = field.value
        control_element << text
        e << control_element
      end
    end

    e
  end
end
