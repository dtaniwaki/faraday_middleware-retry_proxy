require_relative 'retry_proxy_core'

module FaradayMiddleware
  class RetryProxy < RetryProxyCore
    class Options < Faraday::Options.new(:interval, :interval_randomness)
      def self.from(value)
        if Fixnum === value
          new(value)
        else
          super(value)
        end
      end

      def interval
        (self[:interval] ||= 0).to_f
      end

      def interval_randomness
        (self[:interval_randomness] ||= 0).to_f
      end
    end

    def initialize(app, options = nil)
      super(app)
      @options = Options.from(options)
    end

    def normalize_proxies(proxy)
      proxies = super
      proxies.map{ |p| Faraday::ProxyOptions.from(p) }
    end
  end
end
