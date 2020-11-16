# frozen_string_literal: true

json.extract! @marc_record, :id, :marc001, :bytecount, :length, :checksum
json.url download_url(@marc_record.file)
json.marc21 marc21_organization_marc_record_url(@organization, @marc_record)
json.marcxml marcxml_organization_marc_record_url(@organization, @marc_record)
