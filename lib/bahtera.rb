require "bahtera/version"
require 'addressable/uri'
require 'multi_json'

module Bahtera
  class << self
    BASE_URL    = "http://kateglo.bahtera.org/api.php"
    BASE_PARAMS = { format: 'json' }

    def lookup(word)
      uri = Addressable::URI.parse BASE_URL
      uri.query_values = BASE_PARAMS.merge(phrase: word)
      MultiJson.load Kernel.open(uri.to_s)
    end
  end
end
