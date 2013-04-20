require "bahtera/version"
require 'net/http'
require 'addressable/uri'
require 'multi_json'

module Bahtera
  class RequestError < StandardError; end

  class << self
    BASE_URL    = "http://kateglo.bahtera.org/api.php"
    BASE_PARAMS = { format: 'json' }

    def lookup(word)
      if word =~ /\s/
        word.split(' ').map do |w|
          begin
            lookup(w)
          rescue MultiJson::LoadError
          end
        end
      else
        uri = Addressable::URI.parse BASE_URL
        uri.query_values = BASE_PARAMS.merge(phrase: word)
        response = Net::HTTP.get_response(uri)

        unless response.kind_of? Net::HTTPSuccess
          raise Bahtera::RequestError, "HTTP Response: #{response.code} #{response.message}"
        end
        Kata.new(response.body)
      end
    end
  end

  class Kata
    ATTRIBUTE_NAMES = %w( phrase phrase_type lex_class ref_source def_count
                          actual_phrase info notes updated created
                          lex_class_name root definition reference proverbs
                          translations relation all_relation)

    attr_reader *ATTRIBUTE_NAMES

    def initialize(json_response)
      parsed_json = MultiJson.load json_response
      @json_response = parsed_json['kateglo']
      assign_attribute_names
    end

    private
      def assign_attribute_names
        ATTRIBUTE_NAMES.each do |attr_name|
          if @json_response[attr_name]
            instance_variable_set("@#{attr_name}",
                                    @json_response[attr_name])
          end
        end
      end
  end
end
