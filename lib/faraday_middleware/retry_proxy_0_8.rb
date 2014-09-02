require_relative 'retry_proxy_core'

module FaradayMiddleware
  class RetryProxy < RetryProxyCore
    def initialize(app, options = {})
      super(app)
      @options = options
    end

    def normalize_proxies(proxy)
      proxies = super
      proxies.map do |p|
        uri = URI.parse(p)
        user = uri.user
        password = uri.password
        uri.user = nil
        uri.password = nil
        {uri: uri.to_s, user: user, password: password}
      end
    end
  end
end
