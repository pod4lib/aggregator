# frozen_string_literal: true

##
# Misc. OAI-PMH functionality
module OaiConcern
  extend ActiveSupport::Concern

  # Base class for error conditions: see
  # http://www.openarchives.org/OAI/openarchivesprotocol.html#ErrorConditions
  class OaiError < StandardError; end

  # Raised by any request
  class BadArgument < OaiError
    def message
      'The request includes illegal or repeated arguments, or is missing required arguments'
    end
  end

  # Raised by any request
  class BadVerb < OaiError
    def message
      'The value of the verb argument is missing, repeated, or illegal'
    end
  end

  # Raised by ListIdentifiers, ListRecords, ListSets
  class BadResumptionToken < OaiError
    def message
      'The value of the resumptionToken argument is invalid or expired'
    end
  end

  # Raised by GetRecord, ListIdentifiers, ListRecords
  class CannotDisseminateFormat < OaiError
    def message
      'The metadata format specified by the metadataPrefix argument is not supported by the item or repository'
    end
  end

  # Raised by GetRecord, ListMetadataFormats
  class IdDoesNotExist < OaiError
    def message
      'The value of the identifier argument is unknown or illegal in this repository'
    end
  end

  # Raised by ListIdentifiers, ListRecords
  class NoRecordsMatch < OaiError
    def message
      'The combination of the values of the from, until, set and metadataPrefix arguments returns an empty list'
    end
  end

  # Token for requesting records: base64-encoded combo of filters & page cursor
  # A token lets you construct a list of records and point to somewhere in that
  # list.
  class ResumptionToken
    def self.encode(set, page, from_date, until_date)
      Base64.urlsafe_encode64([set, page, from_date, until_date].join(';'))
    end

    def self.decode(token)
      set, page, from_date, until_date = Base64.urlsafe_decode64(token).split(';')

      begin
        validate(set, page, from_date, until_date)
      rescue ArgumentError
        raise OaiConcern::BadResumptionToken
      end

      [set, page, from_date, until_date]
    end

    def self.validate(set, page, from_date, until_date)
      Integer(set) if set.present?
      Integer(page) if page.present?
      Date.parse(from_date) if from_date.present?
      Date.parse(until_date) if until_date.present?
    end
  end

  # rubocop:disable Metrics/BlockLength
  included do
    private

    # XML namespace values for OAI-PMH, see:
    # https://www.openarchives.org/OAI/openarchivesprotocol.html#XMLResponse
    def oai_xmlns
      {
        'xmlns' => 'http://www.openarchives.org/OAI/2.0/',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd'
      }
    end

    # XML namespace values for OAI-PMH Dublin Core containers
    # Used for the ListSets description, see:
    # http://www.openarchives.org/OAI/openarchivesprotocol.html#ListSets
    def oai_dc_xmlns
      {
        'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
      }
    end

    def list_sets_description(stream)
      [[list_sets_default_status(stream),
        list_sets_stream_info(stream)].join(' '),
       list_sets_date_ranges(stream)].join(', ')
    end

    def list_sets_default_status(stream)
      stream.default? ? 'Current default stream' : 'Former default stream'
    end

    def list_sets_stream_info(stream)
      "for #{stream.organization.slug}"
    end

    def list_sets_date_ranges(stream)
      stream.default_stream_histories.recent.map do |history|
        "#{history.start_time} to #{history.end_time.presence || 'present'}"
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
