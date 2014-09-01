Gem::Specification.new do |gem|
  gem.name        = "faraday_middleware-retry_proxy"
  gem.version     = ::File.read(::File.expand_path('../VERSION', __FILE__)).to_s.strip
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["Daisuke Taniwaki"]
  gem.email       = ["daisuketaniwaki@gmail.com"]
  gem.homepage    = "https://github.com/dtaniwaki/faraday_middleware-retry_proxy"
  gem.summary     = "Retry with proxy in Faraday"
  gem.description = "Retry with proxy in Faraday"
  gem.license     = "MIT"

  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "faraday", ">= 0.8.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", ">= 3.0"
  gem.add_development_dependency "coveralls"
end
