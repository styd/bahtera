require "bahtera/version"
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

  class Kata
    def initialize(hash)
      @hash_response = hash['kateglo']
      assign_attribute_names
    end


    private
      def assign_attribute_names
        attributes = @hash_response.keys
        self.class.class_eval { attr_reader *attributes }
        attributes.each do |attr_name|
          if @hash_response[attr_name]
            instance_variable_set("@#{attr_name}",
                                    @hash_response[attr_name])
          end
        end
      end
  end
end
