module FaradayMiddleware
  class RetryProxy < Faraday::Middleware
    TARGET_ERRORS = [Errno::ETIMEDOUT, Timeout::Error, Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed]

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

    def call(env)
      env[:request] ||= {}
      proxies = self.normalize_proxies(env[:request][:proxy])
      request_body = env[:body]
      begin
        proxy = proxies.pop
        env[:request][:proxy] = proxy ? {uri: URI.parse(proxy)} : nil
        env[:body] = request_body
        @app.call(env)
      rescue *TARGET_ERRORS => exception
        if proxies.size > 0
          sleep (1 + SecureRandom.random_number * @options[:interval_randomness].to_f) * @options[:interval].to_f
          retry
        end
        raise
      end
    end

    def normalize_proxies(proxy)
      if proxy.respond_to?(:call)
        proxy = proxy.call(self)
      end
      proxy ? Array(proxy) : []
    end
  end
end
