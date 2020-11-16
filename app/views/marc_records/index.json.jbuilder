# frozen_string_literal: true

json.meta do
  h = {}
  %I[current_page next_page prev_page total_pages
     limit_value offset_value total_count
     first_page? last_page?].each do |k|
       h[k] = @marc_records.send(k)
     end
  json.pages h
end

json.data do
  json.array! @marc_records do |marc_record|
    json.extract! marc_record, :id, :marc001, :bytecount, :length, :checksum
    json.url organization_marc_record_url(@organization, marc_record)
  end
end
