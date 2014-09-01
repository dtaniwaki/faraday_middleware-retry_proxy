require_relative 'retry_proxy_core'

module FaradayMiddleware
  class RetryProxy < RetryProxyCore
    def initialize(app, options = {})
      super(app)
      @options = options
    end
  end
end
