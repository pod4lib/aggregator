# frozen_string_literal: true

##
# An extension that will be included into the ActiveStorage::Blob class
module ActiveStorageBlobContentTypes
  def analyze
    update! metadata: metadata.merge(extract_metadata_via_analyzer), content_type: marc_content_type
  end

  def marc_content_type
    return content_type unless analyzer.respond_to?(:reader)

    case analyzer.reader.identify
    when :marc21 then 'application/marc'
    when :marcxml then 'application/marcxml+xml'
    else content_type
    end
  end
end
