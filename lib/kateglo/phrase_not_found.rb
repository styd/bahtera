module Kateglo
  class PhraseNotFound
    attr_reader :message, :uri

    def initialize(message, uri)
      @message = message
      @uri = uri
    end
  end
end
