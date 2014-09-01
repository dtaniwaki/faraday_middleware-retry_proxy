require 'rubygems'
require 'coveralls'
Coveralls.wear!

require 'faraday_middleware-retry_proxy'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
end

