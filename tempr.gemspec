require File.expand_path('lib/tempr/version',File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name         = "tempr"
  s.version      = Tempr::Version::STRING
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Eric Gjertsen"]
  s.email        = ["ericgj72@gmail.com"]
  s.homepage     = "http://github.com/ericgj/tempr"
  s.summary      = "No-fussin' temporal expressions library"
  s.description  = ""

  s.files        = `git ls-files -c`.split("\n") - ['tempr.gemspec']
  s.require_path = 'lib'
  s.rubyforge_project = 'tempr'
  s.required_rubygems_version = '>= 1.3.6'
  s.required_ruby_version = '>= 1.9.2'

  s.add_development_dependency 'minitest'
end
