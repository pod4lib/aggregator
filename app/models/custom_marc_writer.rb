# frozen_string_literal: true

##
# A custom MARC writer, because why not.
class CustomMarcWriter < MARC::Writer
  MAX_BYTES = 99_999
  MAX_RECORD_CONTENT = MAX_BYTES - 64 - MARC::LEADER_LENGTH
  def self.encode(record, allow_oversized = false)
    directory = ''
    fields = ''
    offset = 0
    stuff = ''
    record.each do |field|
      # encode the field
      field_data = ''
      if field.class == MARC::DataField 
        warn("Warn:  Missing indicator") unless field.indicator1 && field.indicator2
        field_data = (field.indicator1 || " ") + (field.indicator2 || " ")
        for s in field.subfields
          field_data += MARC::SUBFIELD_INDICATOR + s.code + s.value
        end
      elsif field.class == MARC::ControlField
        field_data = field.value
      end
      field_data += MARC::END_OF_FIELD

      # calculate directory entry for the field
      field_length = field_data.bytesize

      if field_data.bytesize + fields.bytesize + directory.bytesize > MAX_RECORD_CONTENT
        stuff += finalize(record.leader, directory, fields, allow_oversized)
        # Stub out start of next record
        fields = "#{record.fields('001').first.value}#{MARC::END_OF_FIELD}"
        offset = fields.bytesize
        directory = "001#{format_byte_count(fields.bytesize, allow_oversized, 4)}00000"
      end

      directory += sprintf("%03s", field.tag) + format_byte_count(field_length, allow_oversized, 4) + format_byte_count(offset, allow_oversized)

      # add field to data for other fields
      fields += field_data

      # update offset for next field
      offset += field_length
    end

    stuff += finalize(record.leader, directory, fields, allow_oversized)
    stuff
  end

  def self.finalize(leader, directory, fields, allow_oversized)
    # determine the base (leader + directory)
    base = leader + directory + MARC::END_OF_FIELD

    # determine complete record
    marc = base + fields + MARC::END_OF_RECORD

    # update leader with the byte offest to the end of the directory
    marc[12..16] = format_byte_count(base.bytesize, allow_oversized)

    # update the record length
    marc[0..4] = format_byte_count(marc.bytesize, allow_oversized)

    marc
  end
end
