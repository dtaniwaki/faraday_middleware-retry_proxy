module FaradayMiddleware
  class RetryProxyCore < Faraday::Middleware
    TARGET_ERRORS = [Errno::ETIMEDOUT, Timeout::Error, Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed]

    def call(env)
      env[:request] ||= {}
      proxies = self.normalize_proxies(env[:request][:proxy])
      request_body = env[:body]
      begin
        env[:request][:proxy] = proxies.pop
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
      proxies = proxy ? Array(proxy) : []
    end
  end
end
