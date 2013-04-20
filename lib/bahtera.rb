require "bahtera/version"
require 'net/http'
require 'addressable/uri'
require 'multi_json'

module Bahtera
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
    attr_accessor :attributes

    def initialize(json_response)
      @attributes = MultiJson.load json_response
    end
  end
end
