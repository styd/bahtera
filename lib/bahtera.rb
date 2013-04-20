require 'bahtera/version'
require 'bahtera/kata'
require 'net/http'
require 'addressable/uri'
require 'multi_json'

module Bahtera
  class RequestError < StandardError; end

  class << self
    BASE_URL    = "http://kateglo.bahtera.org/api.php"
    BASE_PARAMS = { format: 'json' }

    def lookup(lemma)
      @lemma = lemma
      if @lemma =~ /\s/
        @lemma.split(' ').map do |l|
          begin
            lookup(l)
          rescue MultiJson::LoadError
          end
        end
      else
        @uri = Addressable::URI.parse BASE_URL
        @uri.query_values = BASE_PARAMS.merge(phrase: @lemma)
        response = Net::HTTP.get_response(@uri)

        unless response.kind_of? Net::HTTPSuccess
          raise Bahtera::RequestError, "HTTP Response: #{response.code} #{response.message}"
        end
        parse_response(response.body)
      end
    end


    private
      def parse_response(response)
        begin
          parsed_json = MultiJson.load response
          Kata.new parsed_json
        rescue MultiJson::LoadError
          LemmaNotFound.new("No entry found for '#{@lemma}'", @uri)
        end
      end
  end

  class LemmaNotFound
    attr_reader :message, :uri

    def initialize(message, uri)
      @message = message
      @uri = uri
    end
  end

end
