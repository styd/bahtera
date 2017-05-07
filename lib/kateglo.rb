require 'net/http'
require 'multi_json'
require 'kateglo/version'
require 'kateglo/phrase'
require 'kateglo/cache'
require 'kateglo/phrase_not_found'

module Kateglo
  class RequestError < StandardError; end

  class << self
    BASE_URL    = "http://kateglo.com/api.php"
    BASE_PARAMS = { format: 'json' }

    def lookup(phrase)
      if cached?
        old_result = cache.lookup(phrase)
      end
      if old_result
        raw_result = old_result
      else
        @phrase = phrase
        query = URI.encode_www_form(BASE_PARAMS.merge(phrase: @phrase))
        @uri = URI.parse BASE_URL + "?" + query
        response = Net::HTTP.get_response(@uri)

        unless response.kind_of? Net::HTTPSuccess
          raise Kateglo::RequestError,
                  "HTTP Response: #{response.code} #{response.message}"
        end

        raw_result = MultiJson.load(response.body)["kateglo"]
                              .tap{|h| h.delete("phrase") if h.has_key?("phrase") }
      end
      result = parse_response(raw_result)


      cache.mutex.synchronize do
        cache.push(phrase.freeze, raw_result)
      end if cached? && !old_result

      result
    rescue MultiJson::LoadError
      PhraseNotFound.new("No entry found for '#{@phrase}'", @uri)
    end
    alias_method :[], :lookup

    def cached(value = true)
      @cached = value
    end

    def cached?
      @cached.nil? ? @cached = true : @cached
    end

    def cache(settings_hash = {})
      @cache ||= Cache.new(settings_hash)
    end

    def clear_cache!
      @cache = nil
    end

    private
      def parse_response(response)
        Phrase.new(response)
      end
  end
end
