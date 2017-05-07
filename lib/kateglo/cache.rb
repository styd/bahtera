require 'objspace'

module Kateglo
  # Threadsafe in-process cache for lookup results
  #
  # @author Adrian Setyadi
  class Cache
    attr_reader :settings, :mutex

    def initialize(settings = {})
      @settings = {
        max_size:       100,
        max_memsize:    100000
      }.merge(settings)

      @mutex    = Mutex.new
      @results  = {}
      @size     = 0
      @memsize  = 0
    end

    def settings=(hash)
      @settings = @settings.merge(hash)
    end

    def lookup(phrase)
      mutex.synchronize do
        if @results.has_key? phrase
          result = delete(phrase)
          push(phrase, result)
        else
          return
        end
      end
    end

    def push(phrase, result)
      @results[phrase] = result
    ensure
      house_keeping
    end

    def size
      # Wait for house_keeping to finish
      mutex.synchronize do
        @size
      end
    end

    def memsize
      # Wait for house_keeping to finish
      mutex.synchronize do
        @memsize
      end
    end

    def results
      # Wait for house_keeping to finish
      mutex.synchronize do
        @results
      end
    end

    protected
      def pop
        @results.delete(@results.keys.first)
      end

      def delete(phrase)
        @results.delete(phrase)
      end

      def house_keeping
        pop while @results.size > @settings[:max_size] ||
                ObjectSpace.memsize_of(@results) > @settings[:max_memsize]
        @size = @results.size
        @memsize = ObjectSpace.memsize_of(@results)
      end
  end
end
