$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "token_pagination/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "token_pagination"
  s.version     = TokenPagination::VERSION
  s.authors     = ["maedama"]
  s.email       = ["maedama85@gmail.com"]
  s.homepage    = "http://maedama.hatenablog.com"
  s.description = "Provides page token based pagination for your active record"
  s.summary     = s.description

  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1"
  s.add_dependency "jwt", "~> 1.2.1"

  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "sqlite3", "~> 1.3.10"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"

end
