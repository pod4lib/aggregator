# frozen_string_literal: true

json.array! @marc_records do |marc_record|
  json.extract! marc_record, :id, :marc001, :bytecount, :length, :checksum
  json.url organization_marc_record_url(@organization, marc_record)
end
