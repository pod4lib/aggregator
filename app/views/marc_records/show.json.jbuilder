# frozen_string_literal: true

json.extract! @marc_record, :id, :marc001, :bytecount, :length, :checksum
json.url download_url(@marc_record.file)
