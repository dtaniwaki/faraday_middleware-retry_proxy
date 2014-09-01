if Faraday::VERSION =~ /^0\.8\.\d$/
  load File.expand_path('../retry_proxy_0_8.rb', __FILE__)
  Faraday.register_middleware retry_proxy: FaradayMiddleware::RetryProxy
else
  load File.expand_path('../retry_proxy_0_8.rb', __FILE__)
  Faraday::Request.register_middleware retry_proxy: FaradayMiddleware::RetryProxy
end

FaradayMiddleware::RetryProxy.class_eval do
  VERSION = ::File.read(::File.expand_path('../../../VERSION', __FILE__)).to_s.strip
end
